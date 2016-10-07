figure
% DEM = GRIDobj('./DV_Data/death_valley_fill.tif');
% h = imagesc(DEM);

S = shaperead('./DV_Data/death_valley_poly.shp');

for i = 1:numel(S)
   c = S(i);
   mapshow(c.X,c.Y, 'DisplayType', 'polygon');
end

attr_list = {};

for i = 1:numel(S)
   c = S(i);
   c1 = c.BoundingBox(1,:);
   c2 = c.BoundingBox(2,:);
   cc = [(c1(1)+c2(1))/2, (c1(2)+c2(2))/2];
%    TextZoomable(cc(1),cc(2),num2str(c.GRIDCODE))
end

shape_attr = fieldnames(S);
id_n = find(strcmpi(shape_attr,'ID'));

attribs = shape_attr(id_n:end);
af = attribs{2};

attribs_list = {};
for i = 1:numel(S)
    attribs_list = [attribs_list; num2str(S(i).(af))];
end