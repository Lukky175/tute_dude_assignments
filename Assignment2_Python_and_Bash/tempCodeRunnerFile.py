# Add Numbers
def add(a, b):
    return a + b

# Subtract Numbers
def subtract(a, b):
    return a - b

# Multiply Numbers
def multiply(a, b):
    return a * b

# Divide Numbers
def divide(a, b):
    try:
        return a / b
    except ZeroDivisionError:
        return "Cannot Divide by Zero"

# Infinite Loop
while True:

    print("\n1. Add Numbers")
    print("2. Subtract Numbers")
    print("3. Multiply Numbers")
    print("4. Divide Numbers")
    print("0. Exit Calculator")

    i = int(input("Enter your choice for Operation: "))

    if i == 0:
        break

    a = int(input("Enter the First Number: "))
    b = int(input("Enter the Second Number: "))

    if i == 1:
        print("Your Result is:", add(a, b))

    elif i == 2:
        print("Your Result is:", subtract(a, b))

    elif i == 3:
        print("Your Result is:", multiply(a, b))

    elif i == 4:
        print("Your Result is:", divide(a, b))

    else:
        print("Invalid Input, Try Again")