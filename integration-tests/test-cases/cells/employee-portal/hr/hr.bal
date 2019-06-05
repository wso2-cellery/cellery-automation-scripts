import ballerina/io;
import celleryio/cellery;
//HR component
cellery:Component hrComponent = {
    name: "hr",
    source: {
        image: "docker.io/celleryio/sampleapp-hr"
    },
    ingresses: {
        "hr": <cellery:HttpApiIngress>{
            port: 8080,
            context: "hr-api",
            definition: {
                resources: [
                    {
                        path: "/",
                        method: "GET"
                    }
                ]
            },
            expose: "global"
        }
    },
    envVars: {
        employee_api_url: { value: "" },
        stock_api_url: { value: "" }
    },
    dependencies: {
        employeeCellDep: "wso2cellerytest/employee-cell:1.0.0", //  fully qualified dependency image name as a string
        stockCellDep: <cellery:ImageName>{ org: "wso2cellerytest", name: "stock-cell", ver: "1.0.0" } // dependency as a struct
    }
};

// Cell Initialization
cellery:CellImage hrCell = {
    components: {
        hrComp: hrComponent
    }
};

public function build(cellery:ImageName iName) returns error? {
    return cellery:createImage(hrCell, iName);
}

public function run(cellery:ImageName iName, map<cellery:ImageName> instances) returns error? {
    //Resolve employee API URL
    cellery:Reference employeeRef = check cellery:getReference(instances.employeeCellDep);
    hrComponent.envVars.employee_api_url.value = <string>employeeRef.employee_api_url;

    //Resolve stock API URL
    cellery:Reference stockRef = check cellery:getReference(instances.stockCellDep);
    hrComponent.envVars.stock_api_url.value = <string>stockRef.stock_api_url;
    return cellery:createInstance(hrCell, iName);
}
