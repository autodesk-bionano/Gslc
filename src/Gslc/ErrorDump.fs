module ErrorDump

open System
open System.IO
open System.Text
open commonTypes
open constants
open Amyris.Bio.utils
open shared
open Newtonsoft.Json
open System.Collections.Generic
open PluginTypes
open CoreOutputProviders    
open AstAlgorithms
open Amyris.ErrorHandling
open AstErrorHandling


type AutodeskErrorDumpOutputProvider (outPath: (string) option) =
    inherit ConfigurableOutputProvider<string>(outPath)
    with
    override x.ArgSpec =
        {name = "errordump"; param = ["outfile"]; alias = [];
         desc = "dump out error hash in json format in the specified"}
    override x.UseArg(arg) =
        AutodeskErrorDumpOutputProvider(Some(arg.values.[0]))
        :> IOutputFormat
    override x.DoOutput(path, data) = printfn "%s" path // Dummy method to print out the path.
 
let autodeskErrorDumpOutputPlugin = outputPlugin "Autodesk error output file format" (AutodeskErrorDumpOutputProvider(None))

