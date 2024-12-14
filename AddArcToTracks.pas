//----------------------------------------------------
// Place Tangent Arc.
// Copyright (c) 2011
// Kardium Inc.
//----------------------------------------------------
// This script will combine tracks that form a straight line and overlap.
//....................................................


var
   Board : IPCB_Board;
   PCB_Library : IPCB_LayerObject;
   threshold : extended;
   addedArcs : array[0..1000] of IPCB_Arc;
   addedCount : integer;

//-----------------------------------------------------------------------

// Procedure to add arc to the end of the track, using the center, start and end angles copied from the reference arc.
// This procedure maitains a list of all arcs that have been added and will not add duplicates.
procedure AddArcToTrack(Track : IPCB_Track, refArc : IPCB_Arc);
var
   pi : extended;
   theta, thetadeg : extended;
   x0, y0 : extended;
   xcp, ycp : extended;
   x2p, y2p : extended;
   index1 : integer;
   radius : extended;
   arc : IPCB_Arc;
begin
   pi := 4 * arctan(1.0);
   theta := GetAngle(track.x2 - track.x1, track.y2 - track.y1);
   thetadeg := 180 * theta / pi;

   // Rotate and translate coordinates based on the angle of the track and orgin of track's x1, y1.
   x0 := track.x1;
   y0 := track.y1;
   xcp := (refArc.XCenter-x0) * cos(theta) + (refArc.YCenter-y0) * sin(theta);
   ycp := (refArc.XCenter-x0) * (-sin(theta)) + (refArc.YCenter-y0) * cos(theta);
   x2p := (track.x2-x0) * cos(theta) + (track.y2-y0) * sin(theta);
   y2p := (track.x2-x0) * (-sin(theta)) + (track.y2-y0) * cos(theta);
   radius := abs(ycp);

   // Check to see if arc has already been added;
   arc := Nil;
   for index1 := 0 to addedCount-1 do begin
      if (abs(addedArcs[index1].Radius-radius) < threshold)
         and addedArcs[index1].Layer = track.Layer then begin
         arc := addedArcs[index1];
         break;
      end;
   end;
   // Add arc if needed.
   if arc = Nil then begin
      arc := PCBServer.PCBObjectFactory(eArcObject, eNoDimension, eCreate_Default);
      arc.XCenter := refArc.XCenter;
      arc.YCenter := refArc.YCenter;
      arc.Radius := Radius;
      arc.LineWidth := track.Width;
      arc.Net := track.Net;
      arc.StartAngle := refArc.StartAngle;
      arc.EndAngle := refArc.EndAngle;
      arc.Layer    := Track.Layer;
      arc.Selected := True;
      Board.AddPCBObject(arc);
      addedArcs[addedCount] := arc;
      addedCount := addedCount + 1;
   end;

   // Update track end point to connect to arc.
   PCBServer.SendMessageToRobots(Track.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_noEventData);
   // Test for connection to x1 or x2.
   if abs(xcp) < abs(x2p-xcp) then begin
      // Connection to x1.
      track.x1 := xcp * cos(theta) + x0;
      track.y1 := xcp * sin(theta) + y0;
   end else begin
      track.x2 := xcp * cos(theta) + x0;
      track.y2 := xcp * sin(theta) + y0;
   end;
   sortTrackEnds(Track);
   PCBServer.SendMessageToRobots(Track.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_noEventData);

   PCBServer.SendMessageToRobots(arc.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_noEventData);
   // Ensure that track end point match the track.
   if abs(xcp) < abs(x2p-xcp) then begin
      // Connection to x1.
      if ycp < 0 then
         arc.StartAngle := fmod(thetadeg + 90, 360)
      else
         arc.EndAngle := fmod(thetadeg + 270, 360);
   end else begin
      if ycp < 0 then
         arc.EndAngle := fmod(thetadeg + 90, 360)
      else
         arc.StartAngle := fmod(thetadeg + 270, 360);
   end;
   PCBServer.SendMessageToRobots(arc.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_noEventData);

end;

procedure Main;
var
    Iterator : IPCB_BoardIterator;
    Track  : IPCB_Track;
    Tracks : array[0..1000] of IPCB_Track;
    TrackCount : Integer;
    CountObjects : Integer;
    Arc : IPCB_Arc;
    index1, index2 : Integer;
    Object1 : IPCB_Object;
begin
    threshold := MMsToCoord(0.0005);
    addedCount := 0;

    Board := PCBServer.GetCurrentPCBBoard;
    PCB_Library := PCBServer.GetCurrentPCBLibrary;

    If Board = Nil Then Exit;
    
    
    
    
    // Get the selected tracks/arcs
    // Improves speed over the old script
    CountObjects := Board.SelectecObjectCount;

    TrackCount := 0;
    Arc := Nil;

    for index1 := 0 to CountObjects-1 do begin

        Object1 := Board.SelectecObject(index1);

        if (Object1.ObjectId = eTrackObject) then
        begin
            Tracks[TrackCount] := Object1;
            TrackCount := TrackCount + 1;
        end;
        if (Object1.ObjectId = eArcObject) then
        begin
             Arc := Object1;
        end;
    end;
    
    
    
    

    if (TrackCount < 1) or (Arc = Nil) then begin;
       showmessage('Must have one arc and at least one track selected.');
       exit;
    end;

    PCBServer.PreProcess;

    try
       for index1 := 0 to TrackCount-1 do begin
          AddArcToTrack(tracks[index1], Arc);
       end;
    Finally
       PCBServer.PostProcess;
    End;
    // Refresh PCB workspace.
    ResetParameters;
    AddStringParameter('Action', 'Redraw');
    RunProcess('PCB:Zoom');

End;


