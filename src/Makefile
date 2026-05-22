# RyuOS Tools Makefile

CC = gcc
CFLAGS = -Wall -Wextra -O2
BIN_DIR = ../build-artifacts

all: $(BIN_DIR) $(BIN_DIR)/ryush $(BIN_DIR)/sys-monitor

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(BIN_DIR)/ryush: ryush/ryush.c
	$(CC) $(CFLAGS) -o $@ $^

$(BIN_DIR)/sys-monitor: sys-monitor/sys-monitor.c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(BIN_DIR)/ryush $(BIN_DIR)/sys-monitor
