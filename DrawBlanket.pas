Procedure Main;
Var
    SchDoc : ISch_Document;
    Blanket : ISch_Blanket;

    PointArray : Array[1..4] of TPoint;

    LineIterator : ISch_Iterator;
    Line : ISch_Line;
    i : Integer;

Begin
    // Initialize the robots in Schematic editor.
    If SchServer = Nil Then Exit;
    SchDoc := SchServer.GetCurrentSchDocument;
    If SchDoc = Nil Then Exit;



    LineIterator := SchDoc.SchIterator_Create;
    If LineIterator = Nil Then Exit;
    LineIterator.AddFilter_ObjectSet(MkSet(ePolyline));
    Line := LineIterator.FirstSchObject;
    While Line <> Nil Do
    Begin
        If Line.Selection = True Then
        Begin
            Break;
        End;
        Line := LineIterator.NextSchObject;
    End;
    SchDoc.SchIterator_Destroy(LineIterator);

    If Line.Selection = False Then Exit;

    SchServer.ProcessControl.PreProcess(SchDoc, '');
    Blanket := SCHServer.SchObjectFactory(eBlanket, eCreate_Default);

    For i := 1 To Line.VerticesCount Do
    Begin
        Blanket.InsertVertex(i);
        Blanket.Vertex[i] := Line.Vertex[i];
    End;
    Blanket.Color := $0000FF;
    Blanket.LineWidth := 0;
    Blanket.LineStyle := eLineStyleDotted;
    Blanket.AreaColor := $FFFFFF;
    Blanket.Transparent := True;

    SchDoc.RegisterSchObjectInContainer(Blanket);
    SchDoc.GraphicallyInvalidate;
    SchServer.ProcessControl.PostProcess(SchDoc, '');

    SchServer.ProcessControl.PreProcess(SchDoc, '');
    SchServer.RobotManager.SendMessage(Line.I_ObjectAddress, c_BroadCast, SCHM_BeginModify, c_NoEventData);
    Line.Color := $0000FF;
    Line.LineWidth := 0;
    Line.LineStyle := eLineStyleDotted;
    SchServer.RobotManager.SendMessage(Line.I_ObjectAddress, c_BroadCast, SCHM_EndModify, c_NoEventData);
    SchDoc.GraphicallyInvalidate;
    SchServer.ProcessControl.PostProcess(SchDoc, '');

End;
