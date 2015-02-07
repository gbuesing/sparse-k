SparseK
===

K-Means clustering for sparse data (e.g. bag-of-words representations of text documents.)

Uses Ruby hashes as sparse arrays, e.g.:

```
{ 3=>1, 7=>2, 10=>5 }
```

sparsely represents the array:

```
[0,0,0,1,0,0,0,2,0,0,5]
```
