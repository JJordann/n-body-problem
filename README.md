# Million Body Problem

### Poganjanje programov na več jedrih (primer za 4 jedra)
```julia
$ export JULIA_NUM_THREADS=4
$ julia -p 4
julia> include("million.jl")
julia> @time main()
```
### Izdelava animacije
```bash
$ FPS=20
$ convert -delay 1x$FPS frame????.png out.gif
```



## Primer za naše (nepopolno) osončje
![gif](img/osoncje.gif)

### Vrtilna količina sistema ene gruče teles
![img](img/momentum-single-cluster.png)


## Primer za dve gruči po 30 teles, ki trčita
![gif](img/60teles.gif)


### Vrtilna količina sistema dveh druč teles, ki trčita
![img](img/momentum-two-clusters.png)

## Primer za dve gruči po 75 teles, ki trčita
![gif](img/150teles.gif)

## Primer za mimobežni galaksiji (500 teles)
![gif](img/mimobezni.gif)


## Primer za 2000 teles
![gif](img/pobarvani_big_slow.gif)
![gif](img/pobarvani2000.gif)
![gif](img/mimobezni2000.gif)
