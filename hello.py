# coding=UTF-8

print ('hello python') #this is a comment.

age = 20
name = 'LiuZP'

print('{0} was {1} years old when he wrote this book'.format(name,age))
print(name + ' is ' +str(age) +' years old')
print('{} was {} years old when he wrote this book'.format(name,age))

# 对于浮点数保留小数点后面3位
print('{0:.3f}'.format(1.0/3))
print('{0:.3f}'.format(1/3))
print('{0:.3f}'.format(1000/3))

# 使用下划线填充文本，并保持文字处于中间位置
# 使用 (^) 定义 '___hello___'字符串长度为 11
print('{0:_^11}'.format('hello'))
print('{0:a^11}'.format('hello'))
# 基于关键词输出 'Swaroop wrote A Byte of Python'
print('{name} wrote {book}'.format(name='Swaroop', book='A Byte of Python'))


print('a', end = '')
print('b', end = '\n')
print('c', end=' ')
print('d', end='')

print('This is the first line\nThis is the second line')
print("This is the first sentence.\
This is the second sentence.")
#如果你需要指定一些未经过特殊处理的字符串，比如转义序列，那么你需要在字符串前增加r 或 R 来指定一个 原始（Raw） 字符串。下面是一个例子：
print(r"Newlines are indicated by \n")

i=5
print(i)

i=5;print(i);

i=5
print(i)
i=\
5
 print(i)
