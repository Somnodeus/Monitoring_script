#include <unistd.h>
#include <stdio.h>

int main() {
    printf("Process 'test' is running. PID: %d\n", getpid());
    while (1) {
        // Бесконечный цикл, чтобы программа висела в памяти
        sleep(1);
    }
    return 0;
}
