// Copyright (C) 2023 Sergey Vlasov <sergey@vlasov.me>
// MIT License

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUF_LEN 512
char path_buf[BUF_LEN];

void read_file(char *path, char *buf)
{
    buf[0] = '\0';

    FILE *f = fopen(path, "r");
    if (!f) {  // process no longer exists or something else
        return;
    }

    size_t size = fread(buf, sizeof(char), BUF_LEN, f);
    if (size > 0) {
        buf[size - 1] = '\0';
    }
    fclose(f);
}

void walk(char *pids, int namesc, char *namesv[])
{
    char read_buf[BUF_LEN];
    char *save_ptr = pids;
    char *pid = strtok_r(pids, " ", &save_ptr);
    while (pid) {
        // read process name:
        snprintf(path_buf, BUF_LEN, "/proc/%s/comm", pid);
        read_file(path_buf, read_buf);

        if (read_buf[0] != '\0') {
            for (int i = 0; i < namesc; ++i) {
                if (!strcmp(read_buf, namesv[i])) {  // it's a match
                    // read process state:
                    snprintf(path_buf, BUF_LEN, "/proc/%s/status", pid);
                    read_file(path_buf, read_buf);
                    char *line = strtok(read_buf, "\n");
                    while (line) {
                        const size_t state_pos = 7;
                        if (!strncmp(line, "State:\t", state_pos)) {
                            // stopped (suspended):
                            if (line[state_pos] == 'T') {
                                exit(1);
                            }
                            break;
                        }
                        line = strtok(NULL, "\n");
                    }

                    printf("%s\n", namesv[i]);
                    exit(0);
                }
            }

            snprintf(path_buf, BUF_LEN, "/proc/%s/task/%s/children", pid, pid);
            read_file(path_buf, read_buf);
            if (read_buf[0] != '\0') {
                walk(read_buf, namesc, namesv);
            }
        }

        pid = strtok_r(NULL, " ", &save_ptr);
    }
}

int main(int argc, char *argv[])
{
    if (argc < 3) {
        printf("%s: too few arguments\n", argv[0]);
        printf("usage: %s PID NAME...\n", argv[0]);
        return 2;
    }
    // command names start from 3rd argument
    walk(argv[1], argc - 2, argv + 2);

    return 1;
}
