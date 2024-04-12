// Model headers and config include
#include "bnn_model.h"
#include "test_data.h"

#include <riscv/print.h>
#include <riscv/csr.h>

uint64 gen_start, gen_end;
uint64 gen_counter = 0;

int main() {
    uint64 cycles_start = 0, instr_start = 0;
    uint64 cycles_end = 0, instr_end = 0;

    size_t output_size = num_classes;
    Softmax_t* output_p = sequential_output;

    // Print CSV header for output
    // input, mcpass, class0, class1, ...
    printf("input,mcpass,");
    for(size_t i = 0; i < num_classes; i++) {
        printf("class%i", i);
        if (i != num_classes - 1) printf(",");
    }
    printf("\n");

    for(size_t i = 0; i < NUM_DATA; i++) {
        for(size_t j = 0; j < BNN_MC_PASSES; j++) {
            
            cycles_start = read_mcycle();
            sequential_inference(&data_matrix[FEATURES_PER_DATA*i]);
            cycles_end = read_mcycle();

            // Print prediction
            printf("%i, %i, ", i, j);
            for(size_t k = 0; k < output_size; k++) {
                printf("%i", output_p[k]);
                if (k != output_size - 1) printf(", "); 
            }
            printf("\n");
        }
    }

    printf("Counter %llu\n", cycles_end - cycles_start);
}

