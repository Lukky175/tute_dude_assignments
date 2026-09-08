Dictionary = {}

while True:
    i = int(input("Press 1 to Add a new Student Record\nPress 2 to Update Student Record\nPress 3 to Print all Student Record\nPress 0 to Exit\n"))

    if i == 1 :
        name = input("\nEnter the Name of the Student: ")
        grade = input("Enter the Grade of the Student: ")
        Dictionary[name] = grade
        print("\n"+ name+" added with Grade "+ grade+ " in the System \n\n")

    elif i == 2 :
        name = input("\nEnter the Name of the Student: ")
        grade = input("Enter the Grade of the Student: ")
        Dictionary[name] = grade

    elif i == 3 :
        print(Dictionary)

    elif i==0:
        break
    
    else:
        print("Invalid Choice Try Again")