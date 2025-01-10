#include <stdint.h>

// int8_t foo(int8_t x, int8_t y) {
int32_t foo(int32_t x, int32_t y) {
// int64_t foo(int64_t x, int64_t y) {
    return x < y ? x : y;
}
