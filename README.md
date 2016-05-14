<html>
<body>

<h3>Project Title: Javali-Compiler</h3>

<h3>Course: Compiler Lab</h3>

<h3>Environment: Flex, Bison (Windows)</h3>

<h3>Description</h3>
We have made a compiler which can run the <a href='https://www.dropbox.com/s/sxqydxgmvfn6frd/javali.pdf?dl=0'>Javali</a> Language. 
We have done the following things:
<ul>
<li>Grammer Modification</li>
<li>Syntax Analysis</li>
<li>Addition of syntax error handling mechanism</li>
<li>Generation of Intermediate Code (3AC code)</li>
</ul>
We still have to do:
<ul>
<li>Semantic Analysis</li>
<li>Machine Code generation</li>
<li>Executing the code</li>
</ul>

<h3>How to run</h3>
<ul>
<li>Install flex and bison on windows</li>
<li>copy the files in the 'gnuwin32/bin/'</li>
<li>open cmd</li>
<li>change directory to 'gnuwin32/bin/'</li>
<li>enter: flex javali.l</li>
<li>enter: bison -dy javali.y</li>
<li>enter: gcc lex.yy.c y.tab.c -o javali.exe</li>
<li>enter: javali</li>
<li>...(more steps will be added after semantic analysis)</li>
</ul>
</body>
</html>
