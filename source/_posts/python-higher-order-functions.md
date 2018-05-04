---
title: python高阶函数
tags:
  - python
id: 575
categories:
  - Python
date: 2015-10-10 17:33:39
---

十一7天假期，在家休6天。上班来什么都不想做，好无聊。

到今天才想起来学点东西，还是把以前看过的知识再巩固下，顺便记录下来。

本人学python以来，一直断断续续，没人带，自己慢慢摸索。还没入门，好悲剧。

废话不多说，下面是记录的详细内容：
<!-- more -->
#### 1.把函数作为参数

下面简单编写一个高阶函数：
<pre class="lang:python decode:true">def add(x, y, f):
    return f(x) + f(y)</pre>
如果传入abs作为参数f的值：
<pre class="lang:python decode:true ">add(10, -8, abs)</pre>
根据函数的定义，函数实际执行的代码是：
<pre class="lang:python decode:true ">abs(10) + abs(8)

结果：18</pre>
由于参数x，y和f都可以任意传入，如果f传入其它函数，可以得出不同的返回值

**任务**：利用add(x, y, f)函数，计算

<div>![](http://blog.cenhq.com/wp-content/uploads/2015/10/1.png)</div>

**解答：**

<pre class="lang:python decode:true ">import math

def add(x, y, f):
    return f(x) + f(y)

print add(25, 9, math.sqrt)

结果：8.0</pre>

* * *

#### 2.map()函数

<div>**map()**函数是python内置的高阶函数，它接收一个函数f和一个list，并通过把函数f依次作用在list的每个元素上，得出一个新的list并返回</div>
<div></div>
<div>例如：list [1, 2, 3, 4, 5, 6, 7, 8, 9]</div>
<div></div>
<div>如果希望把list的每个元素都平方，可以用map()函数</div>
<div></div>
<div>因此，我们只需要传入函数f(x)=x*x,就可以利用map()函数来完成这个计算</div>
<div></div>
<div>
<pre class="lang:python decode:true ">def f(x):
    return x*x

print map(f,[1, 2, 3, 4, 5, 6, 7, 8, 9])

结果：[1, 4, 9, 16, 25, 36, 49, 64, 81]</pre>
<div>**注意：**map()不是改变原有的list，而是返回一个新的list。</div>
<div></div>
<div>由于list包含的元素可以是任意类型，因此，map()不仅仅可以处理只包含数值的list，事实上它可以处理包含任意类型的list，只要传入的函数f可以处理这些数据类型。</div>
<div></div>
<div>**任务 ：**假设用户输入的英文名不规范，没有按照首字母大写，后续字母小写的规则，请利用map()函数，把一个list（包含若干不规范的英文名字）变成一个包含规范英文名字的list：</div>
<div>
<div>输入：[‘adam’,’LISA’,’barT’]</div>
<div>输出：[‘Adam’,’Lisa’,’Bart’]</div>
</div>
</div>
<div></div>
<div>
<div>**解答：**</div>
<div>
<pre class="lang:python decode:true ">def s(x):
    return x[0].upper() + x[1:].lower()

print map(s, [‘adam’,’LISA’,’barT’])

结果：[‘Adam’,’Lisa’,’Bart’]</pre>

* * *

#### 3.reduce() 函数

</div>
</div>
<div>**reduce()**函数也是Python内置的一个高阶函数。reduce()函数接收的参数和 map()类似，**一个函数 f，一个list**，但行为和 map()不同，reduce()传入的函数 f 必须接收两个参数，reduce()对list的每个元素反复调用函数f，并返回最终结果值。</div>
<div></div>
<div>例如，编写一个f函数，接收x和y，返回x和y的和：</div>
<div>
<pre class="lang:python decode:true ">def f(x, y):
    return x + y</pre>
<div>调用 **reduce(f, [1, 3, 5, 7, 9])**时，reduce函数将做如下计算：</div>
<div></div>
<div>先计算头两个元素：f(1, 3)，结果为4；</div>
<div>再把结果和第3个元素计算：f(4, 5)，结果为9；</div>
<div>再把结果和第4个元素计算：f(9, 7)，结果为16；</div>
<div>再把结果和第5个元素计算：f(16, 9)，结果为25；</div>
<div>由于没有更多的元素了，计算结束，返回结果25。</div>
<div></div>
<div>上述计算实际上是对 list 的所有元素求和。虽然Python内置了求和函数sum()，但是，利用reduce()求和也很简单。</div>
<div></div>
<div>**reduce()还可以接收第3个可选参数，作为计算的初始值。**如果把初始值设为100，计算：</div>
</div>
<pre class="lang:python decode:true ">reduce(f, [1, 3, 5, 7, 9], 100)</pre>
<div>结果将变为125，因为第一轮计算是：</div>
<div></div>
<div>计算初始值和第一个元素：**f(100, 1)**，结果为**101**。</div>
<div></div>
<div>

**任务**：
<div>Python内置了求和函数sum()，但没有求积的函数，请利用recude()来求积：</div>
<div>输入：[2, 4, 5, 7, 12]</div>
<div>输出：2*4*5*7*12的结果</div>
</div>
**解答**：
<pre class="lang:python decode:true ">def f(x, y):
    return x * y

print reduce(f, [2, 4, 5, 7, 12])

结果：3360</pre>

* * *

#### 4.filter()函数

<div>**filter()**函数是 Python 内置的另一个有用的高阶函数，filter()函数接收一个**函数 f **和一个**list**，这个函数 f 的作用是对每个元素进行判断，返回 True或 False，**filter()根据判断结果自动过滤掉不符合条件的元素，返回由符合条件元素组成的新list。**</div>
<div></div>
<div>例如，要从一个list [1, 4, 6, 7, 9, 12, 17]中删除偶数，保留奇数，首先，要编写一个判断奇数的函数：</div>
<div>
<pre class="lang:python decode:true ">def is_odd(x):
    return x % 2 == 1</pre>
然后，利用filter()过滤掉偶数：
<pre class="lang:python decode:true ">filter(is_odd, [1, 4, 6, 7, 9, 12, 17])

结果：[1, 7, 9, 17]</pre>
利用filter()，可以完成很多有用的功能，例如，删除 None 或者空字符串：
<pre class="lang:python decode:true ">def is_not_empty(s):

    return s and len(s.strip()) &gt; 0
filter(is_not_empty, ['test', None, '', 'str', '  ', 'END'])

结果：['test', 'str', 'END']</pre>
<div>**注意:** s.strip(rm) 删除 s 字符串中开头、结尾处的 rm 序列的字符。</div>
<div></div>
<div>当rm为空时，默认删除空白符（包括'\n', '\r', '\t', ' ')，如下：</div>
<div>
<pre class="lang:python decode:true ">a = '    123'
a.strip()

结果： '123'

a='\t\t123\r\n'
a.strip()

结果：'123'</pre>
**任务：**请利用filter()过滤出1~100中平方根是整数的数，即结果应该是：
<div>[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]</div>
</div>
</div>
**解答：**
<pre class="lang:python decode:true ">import math

def f(x):
    n = int(math.sqrt(x))
    return n*n == x

print filter(f, range(1, 101))

结果：[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]</pre>

* * *

#### 5.自定义排序函数

Python内置的 **sorted()**函数可对list进行排序：
<pre class="lang:python decode:true ">&gt;&gt;&gt;sorted([36, 5, 12, 9, 21])
[5, 9, 12, 21, 36]</pre>
但 **sorted()**也是一个高阶函数，它可以接收一个比较函数来实现自定义排序，比较函数的定义是，传入两个待比较的元素 x, y，**如果 x 应该排在 y 的前面，返回 -1，如果 x 应该排在 y 的后面，返回 1。如果 x 和 y 相等，返回 0。**

因此，如果我们要实现倒序排序，只需要编写一个reversed_cmp函数：
<pre class="lang:python decode:true ">def reversed_cmp(x, y):
    if x &gt; y:
        return -1
    if x &lt; y:
        return 1
    return 0</pre>
这样，调用 sorted() 并传入 reversed_cmp 就可以实现倒序排序：
<pre class="lang:python decode:true ">&gt;&gt;&gt; sorted([36, 5, 12, 9, 21], reversed_cmp)
[36, 21, 12, 9, 5]</pre>
sorted()也可以对字符串进行排序，字符串默认按照ASCII大小来比较：
<pre class="lang:python decode:true ">&gt;&gt;&gt; sorted(['bob', 'about', 'Zoo', 'Credit'])
['Credit', 'Zoo', 'about', 'bob']</pre>
'Zoo'排在'about'之前是因为'Z'的ASCII码比'a'小。

**任务：**对字符串排序时，有时候忽略大小写排序更符合习惯。请利用sorted()高阶函数，实现忽略大小写排序的算法。
<div>输入：['bob', 'about', 'Zoo', 'Credit']</div>
<div>输出：['about', 'bob', 'Credit', 'Zoo']</div>
**解答：**
<pre class="lang:python decode:true ">def n(x,y):
    x = x.lower()
    y = y.lower()
    if x &gt; y:
        return 1
    if x &lt; y:
        return -1
    return 0

&gt;&gt;&gt; sorted(['bob','about','Zoo','Credit'], n)
['about', 'bob', 'Credit', 'Zoo']</pre>

* * *

#### 6.返回函数

<div>Python的函数不但可以返回int、str、list、dict等数据类型，还可以返回函数！</div>
<div></div>
<div>例如，定义一个函数 f()，我们让它返回一个函数 g，可以这样写：</div>
<pre class="lang:python decode:true ">def f():
    print 'call f()...'
    # 定义函数g:
    def g():
        print 'call g()...'
    # 返回函数g:
    return g</pre>
<div>仔细观察上面的函数定义，我们在函数 f 内部又定义了一个函数 g。由于函数 g 也是一个对象，函数名 g 就是指向函数 g 的变量，所以，最外层函数 f 可以返回变量 g，也就是函数 g 本身。</div>
<div></div>
<div>调用函数 f，我们会得到 f 返回的一个函数：</div>
<pre class="lang:python decode:true ">&gt; x = f()  # 调用f()
call f()...
&gt;&gt;&gt; x  # 变量x是f()返回的函数：
&lt;function g at 0x1037bf320&gt;
&gt;&gt;&gt; x()  # x指向函数，因此可以调用
call g()...  # 调用x()就是执行g()函数定义的代码</pre>
请注意区分返回函数和返回值：
<pre class="lang:sh decode:true ">def myabs():
    return abs  # 返回函数

def myabs2(x):
    return abs(x)  # 返回函数调用的结果，返回值是一个数值</pre>
返回函数可以把一些计算延迟执行。例如，如果定义一个普通的求和函数：
<pre class="lang:python decode:true ">def calc_sum(lst):
    return sum(lst)</pre>
调用calc_sum()函数时，将立刻计算并得到结果：
<pre class="lang:python decode:true ">&gt;&gt;&gt; calc_sum([1, 2, 3, 4])
10</pre>
但是，如果返回一个函数，就可以“延迟计算”：
<pre class="lang:python decode:true ">def calc_sum(lst):
    def lazy_sum():
        return sum(lst)
    return lazy_sum</pre>
调用calc_sum()并没有计算出结果，而是返回函数:
<pre class="lang:python decode:true ">&gt;&gt;&gt; f = calc_sum([1, 2, 3, 4])
&gt;&gt;&gt; f
&lt;function lazy_sum at 0x1037bfaa0&gt;</pre>
对返回的函数进行调用时，才计算出结果:
<pre class="lang:python decode:true ">&gt;&gt;&gt; f()
10</pre>
由于可以返回函数，我们在后续代码里就可以决定到底要不要调用该函数。

**任务：**请编写一个函数calc_prod(lst)，它接收一个list，返回一个函数，返回函数可以计算参数的乘积**。**
<pre class="lang:python decode:true ">def calc_prod(lst):
    def aa(x,y):
        return x*y
    def bb():
        return reduce(aa,lst)
    return bb

&gt;&gt;&gt; f = calc_prod([1,2,3,4])
&gt;&gt;&gt; f()
24</pre>

* * *

#### 7.闭包

在函数内部定义的函数和外部定义的函数是一样的，只是他们无法被外部访问：
<pre class="lang:python decode:true ">def g():
    print 'g()...'

def f():
    print 'f()...'
    return g</pre>
将** g** 的定义移入函数 **f** 内部，防止其他代码调用 **g**：
<pre class="lang:python decode:true ">def f():
    print 'f()...'
    def g():
        print 'g()...'
    return g</pre>
但是，考察上一小节定义的 **calc_sum **函数：
<pre class="lang:python decode:true ">def calc_sum(lst):
    def lazy_sum():
        return sum(lst)
    return lazy_sum</pre>
<div>**注意: **发现没法把 **lazy_sum** 移到 **calc_sum** 的外部，因为它引用了**calc_sum** 的参数 **lst**。</div>
<div></div>
<div>像这种内层函数引用了外层函数的变量（参数也算变量），然后返回内层函数的情况，称为**闭包（Closure）**。</div>
<div></div>
<div>**闭包的特点**是返回的函数还引用了外层函数的局部变量，所以，要正确使用闭包，就要确保引用的局部变量在函数返回后不能变。举例如下：</div>
<pre class="lang:python decode:true "># 希望一次返回3个函数，分别计算1x1,2x2,3x3:
def count():
    fs = []
    for i in range(1, 4):
        def f():
            return i*i
        fs.append(f)
    return fs

f1, f2, f3 = count()</pre>
<div>你可能认为调用f1()，f2()和f3()结果应该是1，4，9，但实际结果全部都是 9（请自己动手验证）。</div>
<div></div>
<div>原因就是当count()函数返回了3个函数时，这3个函数所引用的变量 i 的值已经变成了3。由于f1、f2、f3并没有被调用，所以，此时他们并未计算 i*i，当 f1 被调用时：</div>
<div>
<pre class="lang:python decode:true ">&gt;&gt;&gt; f1()
9    # 因为f1现在才计算i*i，但现在i的值已经变为3</pre>
因此，返回函数不要引用任何循环变量，或者后续会发生变化的变量。

**任务：**返回闭包不能引用循环变量，请改写**count()**函数，让它正确返回能计算1x1、2x2、3x3的函数。

考察下面的函数** f**:
<pre class="lang:python decode:true ">def f(j):
    def g():
        return j*j
    return g</pre>
<div>它可以正确地返回一个闭包g，g所引用的变量j不是循环变量，因此将正常执行。</div>
<div></div>
<div>在count函数的循环内部，如果借助f函数，就可以避免引用循环变量i。</div>
<div></div>
<div>**解答：**</div>
</div>
<pre class="lang:python decode:true ">def count():
    fs = []
    for i in range(1, 4):
        def f(j):
            def g():
                return j*j
            return g
        r = f(i)
        fs.append(r)
    return fs

&gt;&gt;&gt; f1,f2,f3 = count()
&gt;&gt;&gt; print f1(), f2(), f3()
1 4 9</pre>

* * *

#### 8.匿名函数<del></del>

<div>高阶函数可以接收函数做参数，有些时候，我们不需要显式地定义函数，直接传入匿名函数更方便。</div>
<div></div>
<div>在Python中，对匿名函数提供了有限支持。还是以map()函数为例，计算 f(x)=x2 时，除了定义一个f(x)的函数外，还可以直接传入匿名函数：</div>
<div>
<pre class="lang:python decode:true ">&gt;&gt;&gt; map(lambda x: x * x, [1, 2, 3, 4, 5, 6, 7, 8, 9])
[1, 4, 9, 16, 25, 36, 49, 64, 81]</pre>
通过对比可以看出，匿名函数 lambda x: x * x 实际上就是：
<pre class="lang:python decode:true ">def f(x):
    return x * x</pre>
<div>关键字lambda 表示匿名函数，冒号前面的 x 表示函数参数。</div>
<div></div>
<div>匿名函数有个限制，就是**只能有一个表达式**，**不写return**，返回值就是该表达式的结果。</div>
<div></div>
<div>使用匿名函数，可以不必定义函数名，直接创建一个函数对象，很多时候可以简化代码：</div>
<div>
<pre class="lang:python decode:true ">&gt;&gt;&gt; sorted([1, 3, 9, 5, 0], lambda x,y: -cmp(x,y))
[9, 5, 3, 1, 0]</pre>
返回函数的时候，也可以返回匿名函数：
<pre class="lang:python decode:true ">&gt;&gt;&gt; myabs = lambda x: -x if x &lt; 0 else x
&gt;&gt;&gt; myabs(-1)
1
&gt;&gt;&gt; myabs(1)
1</pre>
**任务：**利用匿名函数简化以下代码：
<pre class="lang:python decode:true ">def is_not_empty(s):
    return s and len(s.strip()) &gt; 0

filter(is_not_empty, ['test', None, '', 'str', '  ', 'END'])</pre>
**解答：**
<pre class="lang:python decode:true ">print filter(lambda s:s and len(s.strip()) &gt; 0, ['test', None, '', 'str', '  ', 'END’])
['test', 'str', 'END']</pre>
</div>
</div>
