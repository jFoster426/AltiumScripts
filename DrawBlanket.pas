Procedure ConvertPolylineToBlanket;
Var
    SchDoc : ISch_Document;
    Blanket : ISch_Blanket;

    LineIterator : ISch_Iterator;
    Line : ISch_Polyline; // was previously ISch_Line
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
    Blanket.LineStyle := eLineStyleDashed;
    Blanket.AreaColor := $FFFFFF;
    Blanket.Transparent := True;

    SchDoc.RegisterSchObjectInContainer(Blanket);
    SchDoc.GraphicallyInvalidate;
    SchServer.ProcessControl.PostProcess(SchDoc, '');

    SchServer.ProcessControl.PreProcess(SchDoc, '');
    SchDoc.RemoveSchObject(Line);
    SchServer.RobotManager.SendMessage(SchDoc.I_ObjectAddress, c_BroadCast, SCHM_PrimitiveRegistration, Line.I_ObjectAddress);
    SchServer.ProcessControl.PostProcess(SchDoc, '');
End;

Procedure ConvertBlanketToPolyline;
Var
    SchDoc : ISch_Document;
    Line : ISch_Polyline;

    BlanketIterator : ISch_Iterator;
    Blanket : ISch_Blanket;
    i : Integer;

Begin
    // Initialize the robots in Schematic editor.
    If SchServer = Nil Then Exit;
    SchDoc := SchServer.GetCurrentSchDocument;
    If SchDoc = Nil Then Exit;

    BlanketIterator := SchDoc.SchIterator_Create;
    If BlanketIterator = Nil Then Exit;
    BlanketIterator.AddFilter_ObjectSet(MkSet(eBlanket));
    Blanket := BlanketIterator.FirstSchObject;
    While Blanket <> Nil Do
    Begin
        If Blanket.Selection = True Then
        Begin
            Break;
        End;
        Blanket := BlanketIterator.NextSchObject;
    End;
    SchDoc.SchIterator_Destroy(BlanketIterator);

    If Blanket.Selection = False Then Exit;

    SchServer.ProcessControl.PreProcess(SchDoc, '');
    Line := SCHServer.SchObjectFactory(ePolyline, eCreate_Default);

    For i := 1 To Blanket.VerticesCount Do
    Begin
        Line.InsertVertex(i);
        Line.Vertex[i] := Blanket.Vertex[i];
    End;
    Line.Color := $0000FF;
    Line.LineWidth := 1;
    Line.LineStyle := eLineStyleDashed;

    SchDoc.RegisterSchObjectInContainer(Line);
    SchDoc.GraphicallyInvalidate;
    SchServer.ProcessControl.PostProcess(SchDoc, '');

    SchServer.ProcessControl.PreProcess(SchDoc, '');
    SchDoc.RemoveSchObject(Blanket);
    SchServer.RobotManager.SendMessage(SchDoc.I_ObjectAddress, c_BroadCast, SCHM_PrimitiveRegistration, Blanket.I_ObjectAddress);
    SchServer.ProcessControl.PostProcess(SchDoc, '');
End;
