(module  ;; Matrices are stored in contiguous linear arrays, and the memory address is passed in. The number of elements in the matrix is stored at that index and the items are stored in the memory locations after.
    (import "console" "log" (func $log (param i32))) ;; Import console log function
    (import "js" "mem" (memory 1)) ;; Also import a page of memory
    (global $currentAddress (import "js" "global") (mut i32)) ;; Next free memory location
    (func $matmult (param $m1 i32) (param $m2 i32) (param $cols1 i32) (param $cols2 i32) (result i32) (local $i1 i32) (local $i2 i32) (local $resAddr i32) (local $tRes i32) (local $d i32) (local $returnAddr i32)
        ;; Initialize local indexing variables
        i32.const 0
        local.set $i1
        i32.const 0
        local.set $i2

        global.get $currentAddress
        i32.const 4
        i32.add ;;Shift to first element of matrix, we'll set the length later
        local.set $resAddr ;;Use this to access the address of the next open array location

        (block $b1
            (loop $l1 ;; Main loop
                i32.const 0
                local.set $tRes ;;Set local accumulator
                i32.const 0
                local.set $d ;;Set loop variable
                (loop $l2
                    local.get $m1

                    i32.const 4
                    i32.add ;;Shift to first element of matrix

                    i32.const 4 ;;An i32 is 32 bits or 4 bytes
                    local.get $i1
                    local.get $d
                    i32.add ;;i1 + d
                    i32.mul ;;4*(i1+d)
                    i32.add ;;m1 + 4*(i1+d) ==> m1[i1+d]
                    i32.load ;;Load value

                    local.get $m2

                    i32.const 4
                    i32.add ;;Shift to first element of matrix

                    i32.const 4
                    local.get $i2
                    local.get $d
                    local.get $cols2
                    i32.mul ;;d*cols2
                    i32.add ;;i2 + d*cols2
                    i32.mul ;;4*(i2+d*cols2)
                    i32.add ;;m2 + 4*(i2+d*cols2) ==> m2[i2+d*cols2]
                    i32.load ;;Load value

                    i32.mul
                    local.get $tRes
                    i32.add
                    local.set $tRes ;; tRes += (m1[i1+d] * m2[i2+d*cols2]);

                    local.get $d
                    i32.const 1
                    i32.add
                    local.set $d ;; d++

                    local.get $d
                    local.get $cols1
                    i32.lt_s ;;d < cols1
                    br_if $l2
                )
                local.get $resAddr
                local.get $tRes
                i32.store ;;Add to matrix

                local.get $resAddr
                i32.const 4
                i32.add
                local.set $resAddr ;;Increment to next matrix location

                local.get $i2
                i32.const 1
                i32.add
                local.set $i2 ;;i2 += 1
                local.get $i2
                local.get $cols2
                i32.eq
                (if ;;Note that rather than checking if i2 != cols2-1 as in the corresponding JavaScript code, we add 1 to i2 first and compare to cols2
                    (then
                        i32.const 0
                        local.set $i2 ;;i2 = 0

                        local.get $i1
                        local.get $cols1
                        i32.add
                        local.set $i1 ;;i1 += cols

                        local.get $m1
                        i32.load ;;m1.length
                        local.get $i1
                        i32.eq ;;i1 == m1.length
                        br_if $b1 ;;Break out of loop
                    )
                )
                br $l1
            )
        )

        global.get $currentAddress ;; Get start of matrix, where we will store the length

        local.get $resAddr
        global.get $currentAddress
        i32.sub

        i32.const 4
        i32.div_s ;; Each time we add an element, we increase resAddr by 4, plus one additional +4 at the beginning
        i32.const 1
        i32.sub ;;Now the top value on the stack is the number of elements in the new matrix

        i32.store ;;Store the matrix length

        global.get $currentAddress
        local.set $returnAddr ;;Save the matrix start address to return later

        local.get $resAddr
        global.set $currentAddress ;;Change the free memory pointer to the correct location

        local.get $returnAddr ;;Get the return value and return it
    )
    (func $logMat (param $mStart i32) (local $mLen i32) (local $lIdx i32)
        local.get $mStart
        i32.load ;;Load matrix length
        local.set $mLen ;;Store matrix length

        i32.const 0
        local.set $lIdx ;;Initialize loop counter

        (loop $l3
            local.get $lIdx
            i32.const 1
            i32.add
            local.set $lIdx ;;lIdx++

            local.get $mStart
            local.get $lIdx
            i32.const 4
            i32.mul
            i32.add
            i32.load ;;mStart[lIdx]

            call $log

            local.get $lIdx
            local.get $mLen
            i32.ne
            br_if $l3 ;;Loop again if not at end of matrix yet
        )
    )
    (func (export "runCode") (local $mat1 i32) (local $mat2 i32)
        ;;Create two matrices to be multiplied (generated with genMatrix.py)
        global.get $currentAddress
        local.set $mat1
        global.get $currentAddress
        i32.const 9
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 1
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 2
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 3
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 4
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 5
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 6
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 7
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 8
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 9
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress

        global.get $currentAddress
        local.set $mat2
        global.get $currentAddress
        i32.const 12
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 7
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 2
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 3
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 1
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 5
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 3
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 6
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 4
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 3
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 6
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 3
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress
        global.get $currentAddress
        i32.const 2
        i32.store
        global.get $currentAddress
        i32.const 4
        i32.add
        global.set $currentAddress

        (;local.get $mat1
        call $logMat
        local.get $mat2
        call $logMat;)

        local.get $mat1
        local.get $mat2
        i32.const 3 ;;cols1
        i32.const 4 ;;cols2
        call $matmult
        call $logMat
    )
)