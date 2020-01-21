# End User Guide

## Jupyter Notebook Guide

After you log into one of the two JupyterHub nodes and spawn a server, you will be presented with the file browser UI, from which you can upload, download, create and open files. Alternatively, you can also choose to use the more modern [JupyterLab](#jupyterlab) UI.

## File Browser

This is the UI which you use to browse your Notebook's filesystem and interact with the files.

![browser](images/jupyter_browser.jpg)

## Notebook UI

You can create a new Jupyter Notebook with a **Python 3 kernel** by selecting 'New' > 'Python 3'. You will then be presented with the Notebook UI. 

You can run `!nvidia-smi` or `!gpustat` to check if GPUs are accesible from the notebook.

![notebook](images/jupyter_notebook.jpg)

## TensorBoard

```
TODO, but it works
```

## JupyterLab

You can use JupyterLab instead of Jupyter Notebook. Simply replace `tree?` in the URL with `lab`.
