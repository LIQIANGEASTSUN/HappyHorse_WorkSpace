


import os.path

def is_numeric_string_array(arr):
    """
    检查数组中的每个字符串是否可以转换为数字
    """
    for s in arr:
        print(s)
        if not isinstance(s, str):
            return False
        #try:
        #    float(s)
        #except ValueError:
        #    return False
    return True
    
def is_numeric_string_two_array(arr):
    for sub_arr in arr:
       is_numeric_string_array(sub_arr)

def main():

    arr1 = ["Hello", "wo，rld", "ABC"]
    is_numeric_string_array(arr1)
    
    arr2 = [["123", "456"], ["789", "1000"]]
    is_numeric_string_two_array(arr2)


if __name__ == "__main__":
  print("start quickstart")
  main()