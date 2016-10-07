figure
DEM = GRIDobj('./DV_Data/death_valley_fill.tif');
h = imagesc(DEM);

S = shaperead('./DV_Data/catchments_mean_annual.shp');

for i = 1:numel(S)
   c = S(i);
   mapshow(c.X,c.Y, 'DisplayType', 'polygon');
end

for i = 1:numel(S)
   c = S(i);
   c1 = c.BoundingBox(1,:);
   c2 = c.BoundingBox(2,:);
   cc = [(c1(1)+c2(1))/2, (c1(2)+c2(2))/2];
%    TextZoomable(cc(1),cc(2),num2str(c.GRIDCODE))
  th2 = TextZoomable(.5, .1, 'blue', 'color', [0 0 1]);
end
