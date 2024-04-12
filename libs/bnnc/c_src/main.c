// Model headers and config include
// Must be included in this order

#include <bnn/config.h>

#include "bnn_model.h"
#include "test_data.h"

#include <stdio.h>

int main() {
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
            
            sequential_inference(&data_matrix[FEATURES_PER_DATA*i]);
            
            // Print prediction
            printf("%i, %i, ", i, j);
            for(size_t k = 0; k < output_size; k++) {
                printf("%f", FIXTOF(output_p[k], S_Softmax));
                if (k != output_size - 1) printf(", "); 
            }
            printf("\n");
        }
    }
}

