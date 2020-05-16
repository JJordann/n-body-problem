using Distributions
using LinearAlgebra
using Images
using Plots

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

    center_mass = 200000
	
	for cluster in 1:cluster_number
		#generate center of the cluster
		#x_center = rand((-50.0:50.0))
		#y_center = rand((-50.0:50.0))
		#z_center = rand((-50.0:50.0))

        x_center = center[cluster, 1]
        y_center = center[cluster, 2]		
        z_center = center[cluster, 3]		

		x_coordinates = rand(Uniform(-radius, radius), 1, object_number - 1) 
		y_coordinates = rand(Uniform(-radius, radius), 1, object_number - 1) 
		z_coordinates = rand(Uniform(-radius, radius), 1, object_number - 1) 
		
		#get rectangular vector (simiplified)
		for k in 1:object_number - 1
			xVel = x_coordinates[k]
			yVel = - xVel * xVel / y_coordinates[k]
            zVel = rand(Uniform(-abs(xVel), abs(xVel)))
			
			#velocity magnitude adjustment
			vectorL = vector_length(xVel, yVel, zVel)
			r = vector_length(x_coordinates[k], y_coordinates[k], z_coordinates[k])
			#center_mass = 1000.0 
			desired_length = sqrt(center_mass / r)
			
			multiplyer = vectorL / desired_length
			xVel = xVel / multiplyer
			yVel = yVel / multiplyer

			append!(x_vel_together, xVel)
			append!(y_vel_together, yVel)
			append!(z_vel_together, zVel)
			
			#mass = vector_length(xVel, yVel, zVel) * vector_length(xVel, yVel, zVel) * vector_length(x_coordinates[k], y_coordinates[k], z_coordinates[k])
			
			append!(m_together, 1) 
			
		end
		
		#center of the cluster
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


n_of_clusters = 2
n_of_objects_per_cluster = 20

# začetne lokacije centrov galaksij
centers = [-100 -100 0;
            100  100 0]

# začetna hitrost centrov galaksij
initialVel = [1 0 0;
             -1 0 0] .* 0.01

# radij sfere znotraj katere se naključno generirajo planeti
radius = 30

pos_x, pos_y, pos_z, vel_x, vel_y, vel_z, M = 
    generate_starting_conditions(n_of_clusters, n_of_objects_per_cluster, 
                                 centers, radius, initialVel)


pos = [pos_x' ; pos_y' ; pos_z']'
vel = [vel_x' ; vel_y' ; vel_z']'

pos = pos .* 0.1
vel = vel .* 10


G = 10
N = n_of_clusters * n_of_objects_per_cluster

# image size
n = 512

# dolžina koraka Eulerjeve metode
dt = 0.0005

iters = 250;

scale = p -> round.(p .* 10 .+ n/2)


#project = p -> [p[1], p[2]] ./ (p[3] + 1)
project = p -> [p[1], p[2]]


function toImage(pos, frame_number)
    img = zeros(3, n, n)

    for i = 1:N
        xy1 = project(pos[i, :]) 
        xy = scale(xy1) .|> (Integer ∘ round)

        if (xy[1] >= 1 && xy[1] <= n && xy[2] >= 1 && xy[2] <= n)
            img[:, xy[1], xy[2]] = [1, 1, 1]
        end
    end

    save("frame$(1000 + frame_number).png", colorview(RGB, img))
end


# minimalna razdalja, s katero se računa pospešek
# brez te omejitve dobijo telesa ogromen pospešek
# in pobegnejo iz orbite
min_distance = 0

acc = zeros(N, 3)

angular_momentum = []

center_of_mass = [0; 0; 0]
for i in 1:N
    global center_of_mass = center_of_mass .+ (pos[i, :] .* M[i])
end
center_of_mass = center_of_mass ./ sum(M)

for iter in 1:iters
	
	toImage(pos, iter)
    angmom = 0

    for i in 1:N
        for j in 1:N
            if i != j
                dist = norm(pos[j, :] - pos[i, :])
                dist = max(dist, min_distance) 
                acc[i, :] += (G * M[j] ./ (dist .^ 3)) .* (pos[j, :] - pos[i, :])
            end
        end
        
        angmom += (M[i] .* cross(pos[i, :] - center_of_mass, vel[i, :])) |> norm
    end

    append!(angular_momentum, angmom)

    global vel = vel .+ (acc .* dt)
    global pos = pos .+ (vel .* dt)
    global acc = zeros(N, 3)
end

plot(angular_momentum)
