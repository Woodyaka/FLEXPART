%matplotlib inline
import pickle
import numpy as np
import matplotlib
# matplotlib.use('Agg')
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature

def main():
  '''
  Takes a particle possition pkl file from pos2txt and plots all (lat, lon) points where the height is below the bl height.
  '''
    pkl_file = 'pkl_files/MPHASE/AIRTRACER/C319r1t_part_poss.pkl'
    run_name = str(pkl_file[:6])

    with open(pkl_file, 'rb') as f:
        data = pickle.load(f)

    lon = data[:, 0, :]
    lat = data[:, 1, :]
    height = data[:, 2, :]
    bl_height = data[:, 3, :]
    mask = height < bl_height
    lat_subset = lat[mask]
    lon_subset = lon[mask]
        
    plt_dpi = 300
    map_prj = ccrs.NorthPolarStereo()

    fig = plt.figure(figsize=(12, 10), dpi=plt_dpi)
    ax = fig.add_subplot(1, 1, 1, projection=map_prj)
    ax.set_extent([-180, 180, 0, 90], crs=ccrs.PlateCarree())

    # Add features with high transparency
    ax.add_feature(cfeature.LAND, facecolor='lightgray', alpha=0.3)
    ax.add_feature(cfeature.OCEAN, facecolor='lightblue', alpha=0.3)
    ax.add_feature(cfeature.COASTLINE, edgecolor='gray', linewidth=0.5)

    # Plot points
    # scatter = ax.scatter(lon_subset, lat_subset, alpha=0.5, s=0.5,
    #                      transform=ccrs.PlateCarree())

    hb = ax.hexbin(lon_subset, lat_subset, gridsize=1000, bins='log', 
                   transform=ccrs.PlateCarree(), cmap='viridis')

    cbar = fig.colorbar(hb, label='Log10(N)')

    # Add gridlines
    gl = ax.gridlines(draw_labels=False, dms=True, x_inline=False, y_inline=False)
    gl.top_labels = False
    gl.right_labels = False

    plt.title(f'Particles below Boundary Layer Height - {run_name}')

    plt.show(fig)

    # plt.savefig(f'particles_below_bl_{run_name}.png', dpi=plt_dpi, format='png', bbox_inches='tight')
    # plt.close(fig)

    print(f"Plot {run_name} saved successfully.")

    total_part = data.shape[0] * data.shape[2]
    print(f'total part positions: {total_part}')
    print(f'total part positions below: {len(lat_subset)}')

    print(f'percent below: {(len(lat_subset)/total_part)*100}')

if __name__ == '__main__':
    main()
