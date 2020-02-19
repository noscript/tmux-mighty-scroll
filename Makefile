.PHONY: all test benchmark
.NOTPARALLEL: all

pscheck: pscheck.c
	$(CC) $(CFLAGS) -O2 -Wall -Wextra -Werror -Wconversion -pedantic -std=c99 $^ -o $@

benchmark: pscheck
	./benchmark.sh

test: pscheck
	./test.sh

all: pscheck test benchmark
