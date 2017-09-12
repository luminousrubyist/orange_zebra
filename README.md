# orange_zebra
Assign magnetic picks to segments of the ridge

## Objective
Magnetic picks run parallel to the center of seafloor spreading.
This central zone is often jagged, and the magnetic picks that flank the ridge axis generally mirror these sudden turns.
This tool, with human assistance, assigns each pick to a segment.


## Methodology
[This section is outdated and pending updates. TODO: update this section]

1. The program iterates through segments of the ridge axis.

2. For each segment, say a segment S1 drawn from point A (North) to point B (South) , it zooms in on the area surrounding the segment and locates the nearest flowline.

3. The program divides the flowline into regions of spreading in both directions. The program

  I. Superimposes the Eastward portion of the flowline onto point A

  II. Superimposes the Eastward portion of the flowline onto point B

  III. Connects the extreme ends of the two superimposed flowlines, forming a rough quadrilateral

  IV. Draws the quadrilateral and identifies and marks all picks inside the quadrilateral. The user is prompted to add or remove picks from the selection.

  V. When the user has completed selection, all selected picks are removed from the display and assigned to the segment the user specified

4. The process of step 3 is repeated for the other direction, in this case West.
5. The program continues onto segment S2, zooms in on the segment, identifies nearest flowline, steps 2-4 etc. until all flowlines are finished

# Plans
New program: identifies all relevant picks for a ridge segment.
Figure out how many unique chrons are represented in a ridge segment box
Chron-by-chron project all the picks of a certain chron, separately for two sides of a flowline
Project them all onto a flowline that goes through the center of the ridge segment

#0 Second axes to do fine-tuning of data
#1 Implement panes in Projection
#2 Input .segment files into Projection
#3 Apply results of boxing program to projection
