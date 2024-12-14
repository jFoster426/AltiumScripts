procedure Main;
var
   Board    : IPCB_Board;
   Arc      : IPCB_Arc;
   i        : Integer;
   Tr1, Tr2 : IPCB_Track;
begin
   Board := PCBServer.GetCurrentPCBBoard;
   if Board = nil then exit;

   if Board.SelectecObjectCount = 0 then exit;

   for i := 0 to Board.SelectecObjectCount - 1 do
      if Board.SelectecObject[i].ObjectId = eArcObject then
      begin
         Arc := Board.SelectecObject[i];
         Tr1 := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
         Tr1.Width := MMsToCoord(0.01);
         Tr1.Layer := Board.CurrentLayer;

         Tr1.x1 := Arc.XCenter - MMsToCoord(0.1);
         Tr1.y1 := Arc.YCenter;
         Tr1.x2 := Arc.XCenter + MMsToCoord(0.1);
         Tr1.y2 := Arc.YCenter;
         Board.AddPCBObject(Tr1);

         Tr2 := PCBServer.PCBObjectFactory(eTrackObject, eNoDimension, eCreate_Default);
         Tr2.Width := MMsToCoord(0.01);
         Tr2.Layer := Board.CurrentLayer;

         Tr2.x1 := Arc.XCenter;
         Tr2.y1 := Arc.YCenter - MMsToCoord(0.1);
         Tr2.x2 := Arc.XCenter;
         Tr2.y2 := Arc.YCenter + MMsToCoord(0.1);
         Board.AddPCBObject(Tr2);
      end;
   Board.ViewManager_FullUpdate;
end;
