#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define RYUSH_TOK_BUFSIZE 64
#define RYUSH_TOK_DELIM " \t\r\n\a"

/* Function declarations for built-in shell commands */
int ryush_cd(char **args);
int ryush_help(char **args);
int ryush_exit(char **args);

char *builtin_str[] = {
  "cd",
  "help",
  "exit"
};

int (*builtin_func[]) (char **) = {
  &ryush_cd,
  &ryush_help,
  &ryush_exit
};

int ryush_num_builtins() {
  return sizeof(builtin_str) / sizeof(char *);
}

int ryush_cd(char **args) {
  if (args[1] == NULL) {
    // Default to home directory or /root if running as root
    char *home = getenv("HOME");
    if (home == NULL) {
      home = "/root";
    }
    if (chdir(home) != 0) {
      perror("ryush");
    }
  } else {
    if (chdir(args[1]) != 0) {
      perror("ryush");
    }
  }
  return 1;
}

int ryush_help(char **args) {
  (void)args;
  int i;
  printf("╔═════════════════════════════════════════════╗\n");
  printf("║            Welcome to RyuShell              ║\n");
  printf("║   A custom C-based shell for RyuOS CLI      ║\n");
  printf("╚═════════════════════════════════════════════╝\n");
  printf("Type program names and arguments, then hit enter.\n");
  printf("The following are built in:\n");

  for (i = 0; i < ryush_num_builtins(); i++) {
    printf("  %s\n", builtin_str[i]);
  }

  printf("Use 'exit' to log out.\n");
  return 1;
}

int ryush_exit(char **args) {
  (void)args;
  return 0;
}

int ryush_launch(char **args) {
  pid_t pid;
  int status;

  pid = fork();
  if (pid == 0) {
    // Child process
    if (execvp(args[0], args) == -1) {
      perror("ryush");
    }
    exit(EXIT_FAILURE);
  } else if (pid < 0) {
    // Error forking
    perror("ryush");
  } else {
    // Parent process
    do {
      waitpid(pid, &status, WUNTRACED);
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
  }

  return 1;
}

int ryush_execute(char **args) {
  int i;

  if (args[0] == NULL) {
    // An empty command was entered.
    return 1;
  }

  for (i = 0; i < ryush_num_builtins(); i++) {
    if (strcmp(args[0], builtin_str[i]) == 0) {
      return (*builtin_func[i])(args);
    }
  }

  return ryush_launch(args);
}

char *ryush_read_line(void) {
  char *line = NULL;
  size_t bufsize = 0; // getline allocates memory automatically
  if (getline(&line, &bufsize, stdin) == -1) {
    if (feof(stdin)) {
      exit(EXIT_SUCCESS);  // We received an EOF (Ctrl+D)
    } else {
      perror("ryush: read line");
      exit(EXIT_FAILURE);
    }
  }
  return line;
}

char **ryush_split_line(char *line) {
  int bufsize = RYUSH_TOK_BUFSIZE, position = 0;
  char **tokens = malloc(bufsize * sizeof(char*));
  char *token;

  if (!tokens) {
    fprintf(stderr, "ryush: allocation error\n");
    exit(EXIT_FAILURE);
  }

  token = strtok(line, RYUSH_TOK_DELIM);
  while (token != NULL) {
    tokens[position] = token;
    position++;

    if (position >= bufsize) {
      bufsize += RYUSH_TOK_BUFSIZE;
      tokens = realloc(tokens, bufsize * sizeof(char*));
      if (!tokens) {
        fprintf(stderr, "ryush: reallocation error\n");
        exit(EXIT_FAILURE);
      }
    }

    token = strtok(NULL, RYUSH_TOK_DELIM);
  }
  tokens[position] = NULL;
  return tokens;
}

void ryush_loop(void) {
  char *line;
  char **args;
  int status;
  char cwd[1024];
  char hostname[1024];

  if (gethostname(hostname, sizeof(hostname)) != 0) {
    strcpy(hostname, "ryuos");
  }

  do {
    if (getcwd(cwd, sizeof(cwd)) != NULL) {
      // Find the last component of the path for short prompt
      char *last_slash = strrchr(cwd, '/');
      char *dir = (last_slash && *(last_slash + 1) != '\0') ? last_slash + 1 : cwd;
      if (strcmp(cwd, "/") == 0) {
        dir = "/";
      }
      printf("\033[1;36m[%s:%s]\033[0m$ ", hostname, dir);
    } else {
      printf("\033[1;36m[ryuos]\033[0m$ ");
    }
    fflush(stdout);

    line = ryush_read_line();
    args = ryush_split_line(line);
    status = ryush_execute(args);

    free(line);
    free(args);
  } while (status);
}

int main(int argc, char **argv) {
  (void)argc;
  (void)argv;
  // Clear screen on start
  printf("\033[H\033[J");
  printf("  ____        _   ___  ____\n");
  printf(" |  _ \\ _   _| | / _ \\/ ___|\n");
  printf(" | |_) | | | | |/ _ \\\\___ \\\n");
  printf(" |  _ <| |_| | | (_) |__) |\n");
  printf(" |_| \\_\\\\__,_|_|\\\\___/____/\n\n");
  printf(" RyuOS custom shell running. Type 'help' for instructions.\n\n");

  ryush_loop();

  return EXIT_SUCCESS;
}
