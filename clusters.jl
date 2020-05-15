using Distributions
using LinearAlgebra
using Images
using Plots


function generate_starting_conditions(cluster_number, object_number)
	x_together = []
	y_together = []
	z_together = []
	
	x_vel_together = []
	y_vel_together = []
	z_vel_together = []
	
	for cluster in 1:cluster_number
		#generate center of the cluster
		x_center = rand((-50.0:50.0))
		y_center = rand((-50.0:50.0))
		z_center = rand((-50.0:50.0))
		
		
		x_coordinates = rand(Uniform(-5.0,5.0), 1, object_number - 1) 
		y_coordinates = rand(Uniform(-5.0,5.0), 1, object_number - 1) 
		z_coordinates = rand(Uniform(-5.0,5.0), 1, object_number - 1) 
		
		#get rectangular vector (simiplified)
		for k in 1:object_number - 1
			xVel = x_coordinates[k]
			zVel = 0
			yVel = - xVel * xVel / y_coordinates[k]
			
			#make it smaller
			xVel = xVel / 20
			yVel = yVel / 20
			
			append!(x_vel_together, xVel)
			append!(y_vel_together, yVel)
			append!(z_vel_together, zVel)
		end
		
		append!(x_vel_together, 0)
		append!(y_vel_together, 0)
		append!(z_vel_together, 0)
		
		
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
	
	return x_together, y_together, z_together, x_vel_together, y_vel_together, z_vel_together 
end


println("enter number of clusters")
n_of_clusters = parse(UInt8, readline())

println("enter number of object per cluster")
n_of_objects_per_cluster = parse(UInt8, readline())

pos_x, pos_y, pos_z, vel_x, vel_y, vel_z = generate_starting_conditions(n_of_clusters, n_of_objects_per_cluster)
pos = [pos_x' ; pos_y' ; pos_z']'
vel = [vel_x' ; vel_y' ; vel_z']'

G = 2.95912208286e-4
N = n_of_clusters * n_of_objects_per_cluster

# image size
n = 512
dt = 1;
iters = 100;

scale = p -> round.(p .* 3 .+ n/2)

#project = p -> [p[1], p[2]] ./ (p[3] + 1)
project = p -> [p[1], p[2]]

function toImage(pos, frame_number)
    img = zeros(3, n, n)

    for i = 1:N
        xy1 = project(pos[i, :]) 
        xy = scale(xy1) .|> (Integer ∘round)

        if (xy[1] >= 1 && xy[1] <= n && xy[2] >= 1 && xy[2] <= n)
            img[:, xy[1], xy[2]] = [1, 1, 1]
        end
    end

    save("frame$(1000 + frame_number).png", colorview(RGB, img))
end

acc = zeros(N, 3)

for iter in 1:iters
	#println(vel)
	
	toImage(pos, iter);
    for i in 1:N, j in 1:N
        if i != j
            acc[i, :] += (G ./ norm(pos[j, :] - pos[i, :]) ^ 3) .* (pos[j, :] - pos[i, :])
        end
    end
    global vel = vel .+ (acc .* dt)
    global pos = pos .+ (vel .* dt)
    global acc = zeros(N, 3)
    #scatter3d(pos[:, 1], pos[:, 2], pos[:, 3])
end


