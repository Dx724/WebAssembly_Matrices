function matmult(m1, m2, cols1, cols2) { //Assumes that m1 and m2 are matrices with lengths that are multiples of cols1 and cols2 respectively
    i1 = 0; //Index variables for both matrices
    i2 = 0;
    res = [];
    while (1) {
        tRes = 0; //Accumulator for cell
        for (var d = 0; d < cols1; d++) {
            tRes += (m1[i1+d] * m2[i2+d*cols2]);
        }
        res.push(tRes); //Add to output matrix
        if (i2 != cols2 - 1) {
            i2 += 1;
        }
        else {
            i2 = 0;
            i1 += cols1;
            if (i1 == m1.length) {
                break;
            }
        }
    }
    return res;
}
test1 = [1, 2, 3, 4, 5, 6, 7, 8, 9];
test2 = [7, 2, 3, 1, 5, 3, 6, 4, 3, 6, 3, 2];
console.log(matmult(test1, test2, 3, 4)); //Expected result: [26, 26, 24, 15, 71, 59, 60, 36, 116, 92, 96, 57]