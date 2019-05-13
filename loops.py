# -*- coding: utf-8 -*-
"""
Created on Sat May 11 19:45:27 2019

@author: Kavisha
"""
def f(x):
    # Condition of the while loop
    while x < 5 :  
        print("Thank you")
        # Increment the value of the variable "number by 1"
        x = x+1
    
    
    # Take user input
f(2) 

def main():
	x,y =8,8
	
	if(x < y):
		st= "x is less than y"
	
	elif (x == y):
		st= "x is same as y"
	
	else:
		st="x is greater than y"
	print(st)


a=[2,3,10,2,4,8,1]
import numpy as np
def f(a):
    n=len(a)
    b = np.zeros((n,n), dtype=int)
    for i in range(1,n):
        for j in range(0, i):
            if(a[i]>a[j]):
                    b[i,j]=a[i]-a[j]
            else: b[i,j]=-1
    return b, b.max()

f(a)

