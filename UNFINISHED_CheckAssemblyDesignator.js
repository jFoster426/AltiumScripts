var directoryPath = "C:\\Temp\\";
var fileName = "designator_report.txt";
var filePath = directoryPath + fileName;

function abs(num)
{
    if (num > 0) return num;
    return -num;
}

function findLayerByID(layers, layerID)
{
    for (var i = 0; i < layers.length; i++)
    {
        if (layers[i].layerID === layerID)
        {
            return layers[i];
        }
    }
    return { layerID: 0, layerName: "undefined" };
}

function Main()
{
    var fso = new ActiveXObject("Scripting.FileSystemObject");

    if (!fso.FolderExists(directoryPath))
    {
        fso.CreateFolder(directoryPath);
    }

    // Create a new file and write content to it.
    // Use 'true' to overwrite if file exists.
    var file = fso.CreateTextFile(filePath, true);

    var board = PCBServer.GetCurrentPCBBoard;
    if (board == null) return;

    // Get all the layer IDs and layer names on the PCB.
    var stack = board.LayerStack;
    if (stack == null) return;
    var layers = [];
    var layer = stack.First(eLayerClass_All);
    while (layer != null)
    {
        layers.push({layerName: layer.Name, layerID: layer.LayerID});
        layer = stack.Next(eLayerClass_All, layer);
    }
    var mechLayer = board.MechanicalLayerIterator;
    while (mechLayer.Next != null)
    {
        if (mechLayer.LayerObject.UsedByPrims)
        {
            ShowMessage(Layer2String(mechLayer.LayerObject.LayerID) + " " + mechLayer.LayerObject.Name);
        }
    }

    // Find all the components on the PCB.
    var iterator = board.BoardIterator_Create;
    if (iterator == null) return;
    iterator.AddFilter_ObjectSet(MkSet(eComponentObject));
    PCBServer.PreProcess;

    // Loop through all the designators on the PCB.
    var component = iterator.FirstPCBObject;
    while (component != null)
    {
        var currentLayer = findLayerByID(layers, component.Name.Layer);

        // Component designator should not be hidden.
        if (component.Name.IsHidden())
        {
            file.WriteLine(component.Name.Text + " is hidden.");
        }

        // Component designator is not on the right layer.
        if ((currentLayer.layerName != "Top Overlay") &&
            (currentLayer.layerName != "Bottom Overlay") &&
            (currentLayer.layerName != "Top Designator") &&
            (currentLayer.layerName != "Bottom Designator"))
        {
            file.WriteLine(component.Name.Text + " on " + currentLayer.layerName + " is on an un-allowed layer.");
        }


        // Component font should be Sans Serif.
        // if (component...)
        // {
        //     file.WriteLine(component.Name.Text + " has the wrong font.");
        // }

        // Component width should be 0.15 mm if on Top Overlay layer.
        if ((currentLayer.layerName === "Top Overlay") && (abs(component.Name.Width() - MMsToCoord(0.15)) > MMsToCoord(0.001)))
        {
            file.WriteLine(component.Name.Text + " on " + currentLayer.layerName + " has incorrect width or height.");
        }

        // Component width should be 0.15 mm if on Bottom Overlay layer.
        if ((currentLayer.layerName === "Bottom Overlay") && (abs(component.Name.Width() - MMsToCoord(0.15)) > MMsToCoord(0.001)))
        {
            file.WriteLine(component.Name.Text + " on " + currentLayer.layerName + " has incorrect width or height.");
        }

        // Component width should be 0.15 mm if on Top Designator layer.
        if ((currentLayer.layerName === "Top Designator") && (abs(component.Name.Width() - MMsToCoord(0.15)) > MMsToCoord(0.001)))
        {
            file.WriteLine(component.Name.Text + " on " + currentLayer.layerName + " has incorrect width or height.");
        }

        // Component width should be 0.15 mm if on Bottom Designator layer.
        if ((currentLayer.layerName === "Bottom Designator") && (abs(component.Name.Width() - MMsToCoord(0.15)) > MMsToCoord(0.001)))
        {
            file.WriteLine(component.Name.Text + " on " + currentLayer.layerName + " has incorrect width or height.");
        }

        component = iterator.NextPCBObject;
    }

    // Write content to the file
    file.WriteLine("Hello, World!");
    // Close the file to save changes
    file.Close();

    ShowMessage("Done.");
}
