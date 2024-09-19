from PyPopTracker.packs.locations import PopTrackerLocation, PopTrackerSection, PopTrackerMapLocation, export_locations

MAP_NAME = "bg"
BORDER_THICKNESS = 0
MAP_SIZE_PIXEL = 480
LOC_SIZE_WITH_BORDER = 20
LOC_SIZE = LOC_SIZE_WITH_BORDER - BORDER_THICKNESS
MAP_SIZE_LOCS = int(MAP_SIZE_PIXEL/LOC_SIZE_WITH_BORDER)


def main():
    locs : list[PopTrackerLocation] = []
    for x in range(1, MAP_SIZE_LOCS+1):
        for y in range(1, MAP_SIZE_LOCS+1):
            
            def _get_actual_pos(x):
                return int(LOC_SIZE_WITH_BORDER * (x-1) + LOC_SIZE_WITH_BORDER/2)
            name = f"{x}|{y}"
            map_loc = PopTrackerMapLocation(
                _map=MAP_NAME,
                size=LOC_SIZE,
                x=_get_actual_pos(x),
                y=_get_actual_pos(y),
                border_thickness=BORDER_THICKNESS
            )
            sec = PopTrackerSection(
                name=name,
                item_count=0,
                hosted_item="placeholder"
            )
            loc = PopTrackerLocation(
                name=name,
                access_rules=[[f"^$cell_access|{x}|{y}"]],
                visibility_rules=[[f"$cell_visible|{x}|{y}"]],
                sections=[sec],
                map_locations=[map_loc]
            )
            locs.append(loc)
            
    export_locations(locs, out_path='../locations/locations.jsonc')
            

if __name__ == '__main__':
    main()