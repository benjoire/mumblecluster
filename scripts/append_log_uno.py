import uno
import sys
from time import sleep

csv_path = sys.argv[1]
ods_path = sys.argv[2]

local_ctx = uno.getComponentContext()
resolver = local_ctx.ServiceManager.createInstanceWithContext(
    "com.sun.star.bridge.UnoUrlResolver", local_ctx)
ctx = resolver.resolve("uno:socket,host=localhost,port=2002;urp;StarOffice.ComponentContext")

desktop = ctx.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", ctx)

# Open ODS
ods = desktop.loadComponentFromURL("file:///" + ods_path.replace(" ", "%20"), "_blank", 0, ())
sheets = ods.Sheets
log_sheet = sheets.getByName("Log v2")

# Find first empty row
cursor = log_sheet.createCursor()
cursor.gotoEndOfUsedArea(False)
row = cursor.RangeAddress.EndRow + 1

# Read .csv
with open(csv_path, "r", encoding="utf-8") as f:
    fields = f.readline().strip().split("\t")

for col, value in enumerate(fields):
    cell = log_sheet.getCellByPosition(col, row)
    cell.String = value

# Save and exit
ods.store()
ods.close(True)
