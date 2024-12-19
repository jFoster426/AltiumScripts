Var
    SchDoc : ISch_Document;
    Blanket : ISch_Blanket;
    Line : ISch_Polyline;
    i : Integer;
    Iterator : ISch_Iterator;

Procedure ConvertPolylineToBlanket;
Begin
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
Begin
    SchServer.ProcessControl.PreProcess(SchDoc, '');
    Line := SCHServer.SchObjectFactory(ePolyline, eCreate_Default);

    For i := 1 To Blanket.VerticesCount Do
    Begin
        Line.InsertVertex(i);
        Line.Vertex[i] := Blanket.Vertex[i];
    End;
    Line.Color := $FF0000;
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

Procedure Main;
Begin
    // Is line selected
    If SchServer = Nil Then Exit;
    SchDoc := SchServer.GetCurrentSchDocument;
    If SchDoc = Nil Then Exit;

    Iterator := SchDoc.SchIterator_Create;
    If Iterator = Nil Then Exit;
    Iterator.AddFilter_ObjectSet(MkSet(ePolyline));
    Line := Iterator.FirstSchObject;
    While Line <> Nil Do
    Begin
        If Line.Selection = True Then
        Begin
            ConvertPolylineToBlanket();
            SchDoc.SchIterator_Destroy(Iterator);
            Exit;
        End;
        Line := Iterator.NextSchObject;
    End;
    SchDoc.SchIterator_Destroy(Iterator);

    // Is blanket selected
    If SchServer = Nil Then Exit;
    SchDoc := SchServer.GetCurrentSchDocument;
    If SchDoc = Nil Then Exit;

    Iterator := SchDoc.SchIterator_Create;
    If Iterator = Nil Then Exit;
    Iterator.AddFilter_ObjectSet(MkSet(eBlanket));
    Blanket := Iterator.FirstSchObject;
    While Blanket <> Nil Do
    Begin
        If Blanket.Selection = True Then
        Begin
            ConvertBlanketToPolyline();
            SchDoc.SchIterator_Destroy(Iterator);
            Exit;
        End;
        Blanket := Iterator.NextSchObject;
    End;
    SchDoc.SchIterator_Destroy(Iterator);
End;
