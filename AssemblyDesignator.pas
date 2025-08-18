const
    MIN_INDEX = 0;


Procedure Main;
Var
    Board : IPCB_Board;
    Iterator : IPCB_BoardIterator;
    Component : IPCB_Component;
    NumDesignatorsTotal : Integer;
    NumDesignatorsHidden : Integer;
    NumDesignatorsUpdated : Integer;
    CurrentDesignator : IPCB_Text;
    CurrentDesignatorText : String;
    NumStr : String;
    i : Integer;
Begin
    Board := PCBServer.GetCurrentPCBBoard;
    If Board = Nil Then Exit;

    Iterator := Board.BoardIterator_Create;
    If Iterator = Nil Then Exit;
    Iterator.AddFilter_ObjectSet(MkSet(eComponentObject));

    NumDesignatorsTotal := 0;
    NumDesignatorsHidden := 0;
    NumDesignatorsUpdated := 0;

    PCBServer.PreProcess;

    Component := Iterator.FirstPCBObject;
    While Component <> Nil Do
    Begin

         NumDesignatorsTotal := NumDesignatorsTotal + 1;

         If Component.GetState_NameOn <> True Then
         Begin

              NumDesignatorsHidden := NumDesignatorsHidden + 1;

              // Designator is hidden, needs to be on corresponding designator layer
              CurrentDesignator := Component.GetState_Name;

              CurrentDesignatorText := CurrentDesignator.Text;
              NumStr := '';
              For i := 1 To Length(CurrentDesignatorText) Do
              Begin
                   If (CurrentDesignatorText[i] >= '0') And (CurrentDesignatorText[i] <= '9') Then
                      NumStr := NumStr + CurrentDesignatorText[i];
              End;

              If StrToIntDef(NumStr, 0) >= MIN_INDEX Then
              Begin

                   NumDesignatorsUpdated := NumDesignatorsUpdated + 1;

                  PCBServer.SendMessageToRobots(Component.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_NoEventData);
                  PCBServer.SendMessageToRobots(CurrentDesignator.I_ObjectAddress, c_Broadcast, PCBM_BeginModify, c_NoEventData);


                  Case Layer2String(Component.Layer) Of
                       'Top Layer':
                            Begin
                                 // Set text layer to Top Designator
                                 CurrentDesignator.Layer := eMechanical11; // Need to update based on your specific board

                            End;
                       'Bottom Layer':
                            Begin
                                 // Set text layer to Bottom Designator
                                 CurrentDesignator.Layer := eMechanical12; // Need to update based on your specific board
                            End;
                  End;

                  // Set the text rotation to 0 degrees
                  CurrentDesignator.Rotation := 0.00;
                  // Set text width to  0.05 mm
                  CurrentDesignator.Width := MMsToCoord(0.05);
                  // Set text height to 0.2 mm
                  CurrentDesignator.Size := MMsToCoord(0.2);
                  // Set font to Sans Serif
                  CurrentDesignator.FontID := 2; // Sans Serif font

                  // Make it visible
                  Component.SetState_NameOn(True);
                  // Set autoposition to be center
                  Component.ChangeNameAutoposition(eAutoPos_CenterCenter);
                  Component.SetState_NameAutoPos(eAutoPos_CenterCenter);

                  PCBServer.SendMessageToRobots(Component.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);
                  PCBServer.SendMessageToRobots(CurrentDesignator.I_ObjectAddress, c_Broadcast, PCBM_EndModify, c_NoEventData);

                  CurrentDesignator.GraphicallyInvalidate;

              End;

         End;
        Component := Iterator.NextPCBObject;
    End;

    PCBServer.PostProcess;
    Board.BoardIterator_Destroy(Iterator);

    Board.ViewManager_FullUpdate;
    Client.SendMessage('PCB:Zoom', 'Action=Redraw', 255, Client.CurrentView);

    ShowMessage(
        IntToStr(NumDesignatorsTotal) + ' designators found' + #13#10 +
        IntToStr(NumDesignatorsHidden) + ' designators were hidden' + #13#10 +
        IntToStr(NumDesignatorsUpdated) + ' designators were moved to assembly layers'
    );

End;

