using Distributions
using Distributed
using Images
@everywhere using LinearAlgebra
@everywhere using SharedArrays


function main() 
    n_of_clusters = 2
    n_of_objects_per_cluster = 3000

    # image size
    n = 512 + 256

    # dolžina koraka Eulerjeve metode
    dt = 0.0005

    # število iteracij Eulerjeve metode, ki jih bo program izvedel
    iters = 650;

    G = 10
    N = n_of_clusters * n_of_objects_per_cluster

    # radij sfere znotraj katere se naključno generirajo planeti
    radius = 150


    mimobezni = true;

    if(mimobezni) 
        # primer za mimobežni galaksiji
        centers = [-100 -100 0;
                    100  100 0]

        initialVel = [-1 0.75 0;
                       1  -0.75 0] .* 10.0
    else
        # primer za galaksiji, ki trčita
        centers = [-165 -165 0;
                    165  165 0]

        initialVel = [1 0 0;
                     -1 0 0] .* 0.01
    end


    pos_x, pos_y, pos_z, vel_x, vel_y, vel_z, M = 
        generate_starting_conditions(n_of_clusters, n_of_objects_per_cluster, 
                                     centers, radius, initialVel)

    pos = [pos_x' ; pos_y' ; pos_z']' .* 0.1
    vel = [vel_x' ; vel_y' ; vel_z']' .* 10.0

    pos = convert(SharedArray, pos)
    vel = convert(SharedArray, vel)


    for iter in 1:iters
        
        toImage(n, pos, iter, vel);
        
        acc = step(M, G, pos, vel, dt, N)

        vel[:, :] = vel .+ (acc .* dt)
        pos[:, :] = pos .+ (vel .* dt)
        
        display("$iter/$iters")
    end

end # main


function toImage(n, pos, frame_number, velocity)
    
    # skalira točko tako, da je (0, 0) na sredini slike
    # (in da so razdalje med njimi malo večje)
    scale = p -> round.(p .* 10 .+ n/2)

    # (ortografska) projekcija 3D točke na 2D ravnino
    project = p -> [p[1], p[2]]
    
    # ustvari prazno (črno) RGB sliko
    img = zeros(3, n, n)

    # pobarva pripadajoč piksel vsakega telesa
    for i = 1:length(pos[:, 1, 1])
        # določi intenzivnost barve glede na oddaljenost od ravnine z=0
        intensity = 1 / (1 + pos[i, 3]) |> abs
        intensity = intensity > 1 ? 1 : intensity

        # pobarvaj piksel glede na hitrost telesa
        colour = min(1, (norm(velocity[i, :]) / 2500))

        # izračunaj lokacijo piksla, na katerega pade telo
        xy1 = project(pos[i, :]) 
        xy = scale(xy1) .|> (Integer ∘ round)

        # če je piksel na sliki, ga pobarvaj
        if (xy[1] >= 1 && xy[1] <= n && xy[2] >= 1 && xy[2] <= n)
            img[:, xy[1], xy[2]] += ([1, 1, 1] - [0, 1, 1] .* colour) .* intensity
            img[:, xy[1], xy[2]] = img[:, xy[1], xy[2]] .|> (c -> c > 1 ? 1 : c)
        end
    end

    save("frame$(1000 + frame_number).png", colorview(RGB, img))
end


# izvede en korak Eulerjeve metode
@everywhere function step(M, G, pos::SharedArray, vel::SharedArray, dt, N)
    acc = convert(SharedArray, zeros(N, 3))
    @inbounds @sync @distributed for i in 1:N
       for j in 1:N
            if i != j
                dist = norm(pos[j, :] - pos[i, :])
                acc[i, :] += (G * M[j] ./ (dist .^ 3)) .* (pos[j, :] - pos[i, :])
            end
        end
    end
   return acc 
end


function vector_length(x, y, z)
	return sqrt(x*x + y*y + z*z) 
end


function generate_starting_conditions(cluster_number, object_number, center, radius, initialVel)
	x_together = []
	y_together = []
	z_together = []
	
	x_vel_together = []
	y_vel_together = []
	z_vel_together = []
	
	m_together = []

    # najmanjša dovoljena razvalja od središča
    # gruče do generiranega telesa
    min_distance = 10

    center_mass = 200000
	
	for cluster in 1:cluster_number
        x_center = center[cluster, 1]
        y_center = center[cluster, 2]		
        z_center = center[cluster, 3]		

        # generiranje naključne točke znotraj sfere z r = radius
        r = rand(Uniform(min_distance, radius), 1, object_number - 1) 
        α = rand(Uniform(0, 2π), 1, object_number - 1)
        β = rand(Uniform(0, 2π), 1, object_number - 1)

        # pretvorba polarnih koordinat v kartezijske
        x_coordinates = r .* sin.(α) .* cos.(β)
        y_coordinates = r .* sin.(α) .* sin.(β)
        z_coordinates = r .* cos.(α)

		# get orthogonal vector (simplified)
		for k in 1:object_number - 1
			xVel = x_coordinates[k]
			yVel = - xVel * xVel / y_coordinates[k]
            zVel = rand(Uniform(-abs(xVel), abs(xVel)))
			#zVel = 0
			# velocity magnitude adjustment
			vectorL = vector_length(xVel, yVel, zVel)
			r = vector_length(x_coordinates[k], y_coordinates[k], z_coordinates[k])
			desired_length = sqrt(center_mass / r)
			
			multiplier = vectorL / desired_length
			xVel = xVel / multiplier
			yVel = yVel / multiplier

			append!(x_vel_together, xVel)
			append!(y_vel_together, yVel)
			append!(z_vel_together, zVel)
			
			append!(m_together, 1) 
			
		end
		
		# center of the cluster
		append!(m_together, center_mass) 
		
        append!(x_vel_together, initialVel[cluster, 1])
		append!(y_vel_together, initialVel[cluster, 2])
		append!(z_vel_together, initialVel[cluster, 3])
		
		x_coordinates = x_coordinates .+ x_center
		y_coordinates = y_coordinates .+ y_center
		z_coordinates = z_coordinates .+ z_center
		
		append!(x_together, x_coordinates)
		append!(x_together, x_center)
		
		append!(y_together, y_coordinates)
		append!(y_together, y_center)
		
		append!(z_together, z_coordinates)
		append!(z_together, z_center)

	end

	return x_together, y_together, z_together, 
           x_vel_together, y_vel_together, z_vel_together, 
           m_together
end



