#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/sysinfo.h>

static void print_cpu_usage(void) {
    FILE *fp;
    double first[4], second[4];

    fp = fopen("/proc/stat", "r");
    if (!fp) {
        perror("Failed to open /proc/stat");
        return;
    }
    if (fscanf(fp, "%*s %lf %lf %lf %lf", &first[0], &first[1], &first[2], &first[3]) != 4) {
        fclose(fp);
        return;
    }
    fclose(fp);

    usleep(100000);

    fp = fopen("/proc/stat", "r");
    if (!fp) {
        return;
    }
    if (fscanf(fp, "%*s %lf %lf %lf %lf", &second[0], &second[1], &second[2], &second[3]) != 4) {
        fclose(fp);
        return;
    }
    fclose(fp);

    double active = (second[0] + second[1] + second[2]) - (first[0] + first[1] + first[2]);
    double total = (second[0] + second[1] + second[2] + second[3]) -
                   (first[0] + first[1] + first[2] + first[3]);
    if (total <= 0.0) {
        total = 1.0;
    }

    printf("  CPU Usage:    %.2f%%\n", (active / total) * 100.0);
}

static void print_mem_info(void) {
    struct sysinfo si;
    if (sysinfo(&si) != 0) {
        perror("sysinfo failed");
        return;
    }

    unsigned long total_ram = si.totalram * si.mem_unit;
    unsigned long free_ram = si.freeram * si.mem_unit;
    unsigned long buffer_ram = si.bufferram * si.mem_unit;
    unsigned long used_ram = total_ram - free_ram;
    double used_pct = 0.0;

    if (total_ram > 0) {
        used_pct = ((double)used_ram / total_ram) * 100.0;
    }

    printf("  Memory:\n");
    printf("    Total:      %lu MB\n", total_ram / (1024 * 1024));
    printf("    Used:       %lu MB (%.1f%%)\n", used_ram / (1024 * 1024), used_pct);
    printf("    Free:       %lu MB\n", free_ram / (1024 * 1024));
    printf("    Buffers:    %lu MB\n", buffer_ram / (1024 * 1024));
}

static void print_uptime(void) {
    struct sysinfo si;
    if (sysinfo(&si) != 0) {
        return;
    }

    long days = si.uptime / 86400;
    long hours = (si.uptime % 86400) / 3600;
    long minutes = (si.uptime % 3600) / 60;
    long seconds = si.uptime % 60;

    printf("  Uptime:       ");
    if (days > 0) {
        printf("%ldd ", days);
    }
    if (hours > 0) {
        printf("%ldh ", hours);
    }
    if (minutes > 0) {
        printf("%ldm ", minutes);
    }
    printf("%lds\n", seconds);
}

int main(void) {
    printf("+--------------------------------------------+\n");
    printf("|             RyuOS System Status            |\n");
    printf("+--------------------------------------------+\n");

    print_uptime();
    print_cpu_usage();
    print_mem_info();

    printf("----------------------------------------------\n");
    return 0;
}
