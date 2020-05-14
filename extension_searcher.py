# Prints all the files within the directory given which have the file extension given
from os import listdir
from os.path import isdir
from time import time
target_extension = input("target_extension: ")

if target_extension[0] == '.':
        target_extension = target_extension[1::]

directory = input("directory: ")
scannable = [directory]
found = 0
errors = 0

print()
st = time()
while len(scannable) > 0:
        new_scannable = []
        for file in scannable:
                if isdir(file):
                        try:
                                new_scannable += [f'{file}\{new}' for new in listdir(file)]
                        except PermissionError:
                                errors += 1
                elif file.endswith(target_extension):
                        print(file[len(directory) + 1::])
                        found += 1
        
        scannable = new_scannable

print()
print("found", found, "files after", time() - st, "seconds")
print("couldn't open", errors, "folders")
