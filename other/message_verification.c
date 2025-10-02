#include <stdint.h>
#include <stdbool.h>

typedef struct {
    uint8_t values[7][5];
    uint8_t row_verification[7];
    uint8_t col_verification[5];
    uint8_t harmonic_checksum;
} MessageMatrix;

bool verify_message_integrity(MessageMatrix *matrix, uint8_t verification_key) {
    // Verify row checksums (TRUE assertions)
    for (int r = 0; r < 7; r++) {
        uint8_t calculated_sum = 0;
        for (int c = 0; c < 5; c++) {
            calculated_sum += matrix->values[r][c];
        }
        calculated_sum %= 2;
        
        // Apply harmonic transformation
        int harmonic_index = (r * 5) % 7;
        uint8_t expected = (matrix->row_verification[harmonic_index] + verification_key % 13) % 2;
        
        if (calculated_sum != expected) {
            return false;  // Integrity check failed
        }
    }
    
    // Verify column checksums (FALSE assertions)
    for (int c = 0; c < 5; c++) {
        uint8_t calculated_sum = 0;
        for (int r = 0; r < 7; r++) {
            calculated_sum += matrix->values[r][c];
        }
        calculated_sum %= 2;
        
        if (calculated_sum != matrix->col_verification[c]) {
            return false;  // Integrity check failed
        }
    }
    
    // Verify harmonic checksum using 5/13 principle
    uint8_t calculated_harmonic = 0;
    for (int i = 0; i < 35; i++) {
        int r = i / 5;
        int c = i % 5;
        if (matrix->values[r][c]) {
            calculated_harmonic = (calculated_harmonic + (i * 5) % 13) % 13;
        }
    }
    
    return (calculated_harmonic == matrix->harmonic_checksum);
}