#include <stdio.h>

void matmult(int buf[], int m1[], int m1len, int m2[], int cols1, int cols2) { //Fills into buffer
    int i1 = 0;
    int i2 = 0;
    //int[m1len/cols1*cols2] res;
    int rIdx = 0; //Current index in res
    while (1) {
        int tempRes = 0; //Accumulator for cell
        int d;
        for (d = 0; d < cols1; d++) {
            tempRes += (m1[i1+d] * m2[i2+d*cols2]);
        }
        buf[rIdx] = tempRes; //Add computed element to matrix
        rIdx += 1; //Increment rIdx
        if (i2 != cols2 - 1) {
            i2 += 1;
        }
        else {
            i2 = 0;
            i1 += cols1;
            if (i1 == m1len) {
                break;
            }
        }
    }
}

int main() {
    int test1[9] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    int test2[12] = {7, 2, 3, 1, 5, 3, 6, 4, 3, 6, 3, 2};
    int resultBuffer[12];
    matmult(resultBuffer, test1, sizeof(test1)/sizeof(test1[0]), test2, 3, 4);

    int i;
    for (i = 0; i < 12; i++) {
        printf("%i ", resultBuffer[i]);
        /*if ((i + 1) % 4 == 0) {
            printf("\n");
        }*/
    }
    printf("\n");

    return 0;
}