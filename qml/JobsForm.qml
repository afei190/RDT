import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import SimCenter.RDT 1.0

Dialog {
    title: "Job Manager"
    standardButtons: Dialog.Ok
    height: 480
    width: 1280

    property alias model: jobslistView.model
    property RDT rdt
    property TextViewer textViewer

    SplitView{
        anchors.fill: parent



        ColumnLayout{
            Layout.minimumWidth: 600

            Text {
                text: qsTr("Jobs Listing")
                font.pointSize: 10
            }

            TableView{
                Layout.fillHeight: true
                Layout.fillWidth: true

            id: jobslistView

            onRowCountChanged:
            {
                if(rowCount > 0)
                    rdt.getJobDetails(0)
            }

            onClicked:
            {
                rdt.getJobDetails(currentRow)
            }

            TableViewColumn
            {
                id: nameCol
                title: "Name"
                role: "Name"
                movable: false
                width: 180

            }

            TableViewColumn
            {
                title: "Status"                
                role: "Status"
                movable: false
                width: 60
            }

            TableViewColumn
            {
                title: "Date"
                movable: false
                width: 80
                delegate: Text {
                    text: model.Created.substring(0, 10)
                    horizontalAlignment : Text.AlignHCenter

                }
            }

            TableViewColumn
            {
                title: "Id"
                role: "Id"
                movable: false
                width: 250
            }
        }
        }

        ColumnLayout
        {

            Text {
                text: qsTr("Job Details")
                font.pointSize: 10

            }

            TreeView
            {
                Layout.fillHeight: true
                Layout.fillWidth: true
            model: rdt.jobDetails



            onModelChanged: {
                //TODO:: expand inputs and outputs
                console.log("model changed")
                expand(model.index(10,0))
                expand(model.index(11,0))
            }

            TableViewColumn
            {
                title: "Name"
                role: "Name"
                width: 120

            }

            TableViewColumn
            {
                title: "Value"
                role: "Value"
                width: 480
                delegate: RowLayout{
                    Text{
                        id: valueText
                        text: {
                            if (model && model.Value)
                                return model.Value
                            else
                                return ""
                        }
                    }


                    Button{
                        text: {
                            if(valueText.text.endsWith(".csv"))
                                return "Load"
                            else if(valueText.text.includes("logs.zip"))
                                return "Download"
                            else
                                return "Show"
                        }
                        visible: valueText.text.endsWith(".csv") ||
                                 valueText.text.endsWith(".out") ||
                                 valueText.text.endsWith(".err") ||
                                 valueText.text.endsWith(".log") ||
                                 valueText.text.includes("logs.zip") ||
                                 valueText.text.includes("WorkflowTasks")

                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignRight

                        onClicked: {
                            if(valueText.text.endsWith(".zip"))
                            {
                                fileDialog.output = valueText.text
                                fileDialog.open()
                            }
                            else
                            {
                                rdt.loadResultFile(valueText.text)
                                if(!valueText.text.endsWith(".csv"))
                                    textViewer.open()
                            }
                        }
                    }
                }
            }

            FileDialog {
                id: fileDialog
                property string output

                title: "Please select file location to save"
                nameFilters: [ "Zip files (*.zip)", "All files (*)" ]
                selectExisting: false
                selectMultiple: false
                onAccepted: {
                    rdt.downloadOutputFile(output, fileDialog.fileUrl)
                }

            }
        }
        }
    }
}
