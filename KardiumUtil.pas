//----------------------------------------------------
// Kardium Utility Functions.
// Copyright (c) 2011
// Kardium Inc.
//----------------------------------------------------


procedure sortTrackEnds(Track : IPCB_Track);
var
   x, y : extended;
begin
   if (Track.X2 < Track.X1) or ((Track.X2 = Track.X1) and (Track.Y2 < Track.Y1)) then begin
      x := Track.X1;
      y := Track.Y1;
      Track.X1 := Track.X2;
      Track.Y1 := Track.Y2;
      Track.X2 := x;
      Track.Y2 := y;
   end;
end;


Function GetAngle(x, y : Extended) : Extended;
Var
   theta : extended;
Begin
    if abs(x) > abs(y) then
    Begin
       theta := arctan(y/x);
       if x < 0 then
          theta := theta + 4.0 * arctan(1.0);
    end
    else
    begin
       theta := 2.0 * arctan(1.0) - arctan(x/y);
       if y < 0 then
          theta := theta + 4.0 * arctan(1.0);
    end;
    Result := theta;
End;

Function fmod(x,d : Extended) : Extended;
var
   a : extended;
Begin
   if x >= 0 then
      a := d * frac(x/d)
   else
      a := d * (1-frac(-x/d));
   Result := a;
end;


