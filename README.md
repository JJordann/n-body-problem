# Million Body Problem

### Poganjanje programov na več jedrih (primer za 4 jedra)
```julia
$ export JULIA_NUM_THREADS=4
$ julia -p 4
julia> @everywhere include("clusters.jl")
julia> @time main()
```

## Primer za naše (nepopolno) osončje
![gif](test2.gif)

### Vrtilna količina sistema ene gruče teles
![img](momentum-single-cluster.png)


## Primer za dve gruči po 30 teles, ki trčita
![gif](60teles.gif)


### Vrtilna količina sistema dveh druč teles, ki trčita
![img](momentum-two-clusters.png)

## Primer za dve gruči po 75 teles, ki trčita
![gif](out2.gif)

## Primer za mimobežni galaksiji (500 teles)
![gif](mimobezni.gif)


## Primer za 2000 teles
![gif](pobarvani_big_slow.gif)
![gif](pobarvani2000.gif)
![gif](mimobezni2000.gif)
