/// top-level entry point for GSLc.
/// Injects plugins into main compiler function call.
open System.IO
open gslc
open CoreOutputProviders
open JsonAssembly
open BasicCodonProvider
open BasicAlleleSwapProvider
open BasicL2ExpansionProvider
open utils
open commonTypes
open commandConfig
open LexAndParse
open gslcProcess // Top-level compiler operations
open AstAlgorithms
open Amyris.ErrorHandling
open AstErrorHandling
// Helper libs for oligo design, sequence parsing all in Amyris.Bio.dll
// These imports are only needed for the temporary primer test function below.
open Amyris.Bio
open primercore
open utils
open constants
open PluginTypes
open AstTypes
open ProcessCmdLineArgs
open Newtonsoft.Json
open ErrorDump

let allPlugins = 
    basicOutputPlugins@
    [autodeskJsonOutputPlugin;
     autodeskErrorDumpOutputPlugin;
     basicCodonProviderPlugin;
     basicAlleleSwapPlugin;
     basicL2ExpansionPlugin;]

type ErrorJson =
    {startPosition: string;
      endPosition: string;
      message: string;
      stackTrace: string;
      summary: string;
}

let dumpErrorInfo (errors: AstMessage list, outFile: string) =
    use outF = new StreamWriter(outFile)
    let errorHash = 
        errors
        |> List.map(fun a->
            {startPosition = (match a.sourcePosition with | None -> "" | Some postion -> postion.ToString()); // TODO: format this.
            endPosition = (match a.sourcePosition with | None -> "" | Some postion -> postion.ToString()); // TODO: format this.
            message = a.msg.ToString();
            stackTrace = (match a.stackTrace with | None -> "" | Some st -> st.ToString());
            summary = a.Summary.ToString();
        })

    let errorHashSerialized:string = Newtonsoft.Json.JsonConvert.SerializeObject(errorHash, Formatting.Indented)
    outF.WriteLine(errorHashSerialized)


let handleCompileResultAndErrors (result, input: GslSourceCode, s) =
    match result with
    | Ok((assemblies, tree: AstTreeHead), warnings) ->
        // print any warnings from compilation
        for w in deduplicateMessages warnings do printfn "%s\n" w.Summary
        // if we just want one expansion step, reprint expanded source and done
        if not s.opts.iter || s.opts.onlyPhase1 then
            Exit(0, Some(decompile tree.wrappedNode))
        // do output generation
        else
            Continue(assemblies, s)
    | Bad(errors) ->
        // convert messages into strings for printing
        let msgs = [for msg in deduplicateMessages errors -> msg.Longform(s.opts.verbose, input.String)]
        // TODO: Dump this into a path specified by the --errordump flag instead of /tmp
        dumpErrorInfo(errors, "/tmp/errordump.json")
        Exit(1, Some(msgs |> String.concat "\n\n"))


/// Main function call to run GSLc from the command line.
/// Clients of GSLCore may wish to bypass this function and write their own version if they want
/// to intercept the output from the various compiler stages.
let gslcCustom unconfiguredPlugins argv : FlowControl<_> =

    // Configure GSLc and plugins from command line arguments
    configureGslc unconfiguredPlugins argv
    >?> runCompiler
    >?> handleCompileResultAndErrors
    >?> doAssemblyTransform
    >?> handleTransformResult
    >?> doOutput

[<EntryPoint>]
let main argv =
    try
        let flowResult = gslcCustom allPlugins argv
        match flowResult with
        | Exit(code, msg) ->
            msg |> Option.map (printf "%s") |> ignore
            exit code
        | Continue(_) ->
            printfn "InternalError: GSL relinquished flow control in the continue state."
            exit 1

    with e ->
        printfn "InternalError:\n%s" (prettyPrintException e)
        exit 1
