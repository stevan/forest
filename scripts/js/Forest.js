
//////////////////////////////////////////
function namespace (name) {
    try       { eval(name) } 
    catch (e) { // catch the initial Reference error here
        // build the name
        var parts = name.split('.');
        var recombined;
        for (var i = 0; i < parts.length; i++) {
            if (recombined == undefined) {
                recombined = parts[i];
            }
            else {
                recombined += '.' +  parts[i];
            }
            try       { if (eval(recombined) == undefined) throw Error } 
            catch (e) { eval(recombined + ' = function () {}')         }
        }
    
    }
}
/////////////////////////////////////////

namespace('Forest');

Forest.VERSION   = '0.0.1';
Forest.AUTHORITY = 'jsan:STEVAN';

/////////////////////////////////////////
// create a base class 

Forest.Object = function () {};

Forest.Object.prototype.__OID = 0;

Forest.Object.prototype.get_oid = function () {
    if (!this.oid) {
        this.oid = 'oid_' + ++Forest.Object.prototype.__OID;
        eval(this.oid + '=this');    
    }
    return this.oid;
};

