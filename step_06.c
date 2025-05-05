#define NS16550_BASE_ADDR (0x10000000)
#define NS16550_THR (NS16550_BASE_ADDR + 0x00)
#define NS16550_IER (NS16550_BASE_ADDR + 0x01)
#define NS16550_IER_THR_EMPTY (1 << 1)

void uart_write(const char* ptr) {
    unsigned char* ns16550_ier = (unsigned char*) NS16550_IER;
    char* ns16550_thr = (char*)NS16550_THR;

    while (*ptr != '\0') {
        while (*ns16550_ier & NS16550_IER_THR_EMPTY);
        *ns16550_thr = *ptr++;
    }
}
int main(void) {
    const char* message = "Hello from RISC-V virtual implementation running in QEMU!\n";
    uart_write(message);
    return 0;
}

void semihost(int cause) {
    asm volatile(
        ".option norvc\n" // Mandatory! Semihost does not used compact instructions
        "slli zero, zero, 0x1f\n"
        "ebreak\n"
        "srai zero, zero, 0x7\n"
    );
}

void _start(void) __attribute__((__section__(".start")));
void _start(void) {
    asm volatile(
        "la    sp, stack_top\n"
        "jal   main\n"
    );
    semihost(0x18); // SYS_EXIT
}
