.pragma library

function parseConfig(text) {
    if (!text.trim())
        throw new Error("The selected configuration is empty.");
    var config = JSON.parse(text);
    if (!config || !Array.isArray(config.data))
        throw new Error("The configuration must contain a data array.");
    return config.data.map(function (entry) {
        if (!entry || Array.isArray(entry) || typeof entry.fileName !== "string" || !entry.fileName)
            throw new Error("Each data entry must name a local point file.");
        var row = {translation_x: 0, translation_y: 0, y_value: 0, rotate: 0,
                   zoom: 1, global_box_x: 0, global_box_y: 0, global_box_w: 0,
                   global_box_h: 0, fileName: entry.fileName, lineColor: "#FFF"};
        Object.keys(row).forEach(function (key) {
            if (entry[key] === undefined)
                return;
            if (typeof row[key] === "number") {
                if (typeof entry[key] !== "number" || !isFinite(entry[key]))
                    throw new Error("Invalid numeric value: " + key);
            } else if (typeof entry[key] !== "string") {
                throw new Error("Invalid text value: " + key);
            }
            row[key] = entry[key];
        });
        return row;
    });
}
