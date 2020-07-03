def wat_matrix(arr, matName=""):
    #Store initial address
    if len(matName) > 0:
        print("global.get $currentAddress")
        print("local.set $" + matName)
    
    #Store length
    print("global.get $currentAddress")
    print("i32.const", len(arr))
    print("i32.store")
    incrCA()

    for item in arr:
        print("global.get $currentAddress")
        print("i32.const", item)
        print("i32.store")
        incrCA()

def incrCA():
    print("global.get $currentAddress")
    print("i32.const 4")
    print("i32.add")
    print("global.set $currentAddress")

test1 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
test2 = [7, 2, 3, 1, 5, 3, 6, 4, 3, 6, 3, 2]

wat_matrix(test1, "mat1")
print("")
wat_matrix(test2, "mat2")
