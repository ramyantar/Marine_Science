data1 = load('2021-drifter.mat') ;
model_data= load('Tbay_current_Wind_data.mat');
day = 1 ; 
drif= 1:7 ; 
depth = "Surface" ; 
dt = 1/60 ; 

start_time = data1.deploy_time{day} ;
start_point = data1.deploy_lat_long{day} ; 
end_time = data1.retrieve_time{day} ; 

deploy_time= start_time(drif) ;
ret_time = end_time(drif) ;
dep_lat = start_point(1,drif) ; 
dep_long = start_point(2,drif) ; 


drifters = struct('LONG', [], 'LAT', [], 'coast_check', []);
for i = 1:length(dep_long)
    drifters(i).LONG(1) = dep_long(i);
    drifters(i).LAT(1) = dep_lat(i);
    drifters(i).coast_check = true;
end


time = model_data.time;  z = 0:1: length(time)-1 ; 
velocit = model_data.U_current; V = model_data.V_current; 
longtitude = model_data.xx; LAT_data = model_data.yy;


[y_grid, x_grid, z_grid] = meshgrid(LAT_data(1,:), longtitude(:,1),z) ;

U_mesh = squeeze(velocit(:,:,depth_val,:)) ;
V_mesh = squeeze(V(:,:,depth_val,:)) ;


long_conv = 60*60/ 78567 ;
lat_conv = 60*60/ 110000 ;



quiverplot = quiver(longtitude, LAT_data, velocit(:, :, depth_val, 1), V(:, :, depth_val, 1), "Color", "b");
xlabel("Longitude")
ylabel("Latitude")
hold on

t_range = deploy_time: dt: ret_time ; 

for t = 1: length(t_range) 
    for i = 1:length(dep_long)
        plot( drifters(i).LONG(t), drifters(i).LAT(t), 'or' )
        hold on
    end

    for i = 1:length(dep_long)
        plot( drifters(i).LONG, drifters(i).LAT, 'k', 'MarkerSize', 12, 'LineWidth', 2)
        hold on
    end
    

    for i = 1:length(dep_long)
        u = interp3( y_grid, x_grid, z_grid, U_mesh , drifters(i).LAT(t), drifters(i).LONG(t), t ) ;
        v = interp3( y_grid, x_grid, z_grid, V_mesh , drifters(i).LAT(t), drifters(i).LONG(t), t ) ;
    
        drifters(i).LONG(t+1) = drifters(i).LONG(t) + u*long_conv*dt ;
        drifters(i).LAT(t+1) = drifters(i).LAT(t) + v*lat_conv*dt ;
    end
  
    
    axis([min(longtitude) max(longtitude) min(LAT_data) max(LAT_data)])
    

    
end

legend('virtual drifter trajectory')
