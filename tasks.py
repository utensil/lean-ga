"""
This file specifies tasks mostly for generating the blueprint for formalizing Geometric Algebra.

Check out blueprint/README.md for more information. 
"""

import os
import warnings
import shutil
from pathlib import Path
from invoke import run, task

import http.server
import socketserver

ROOT = Path(__file__).parent
BP_DIR = ROOT/'blueprint'

@task
def decls(ctx):
    """
    Collect Lean declarations from Lean sources for referencing in the blueprint
    """

    try:
        from mathlibtools.lib import LeanProject

        proj = LeanProject.from_path(ROOT)
        proj.pickle_decls(ROOT/'decls.pickle')
    except ImportError:
        warnings.warn("Failed to make URLs for Lean 3 (run `pip install mathlibtools` to fix for now)")
        warnings.warn("Lean 3 is no longer supported, please upgrade to Lean 4")
        raise

@task
def bp(ctx):
    """
    Build the blueprint PDF file and prepare src/web.bbl for task `web`
    """

    cwd = os.getcwd()
    os.chdir(BP_DIR)
    run('mkdir -p print && cd src && tectonic -Z shell-escape-cwd=. --keep-intermediates --outdir ../print print.tex')
    run('cp print/print.bbl src/web.bbl')
    os.chdir(cwd)

@task
def bptex(ctx):
    """
    Build the blueprint PDF file and prepare src/web.bbl for task `web` using old-fashioned TeXLive
    This task is handy if one can't install Tectonic like there's no
    https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.14.1/tectonic-0.14.1-aarch64-unknown-linux-gnu.tar.gz 
    """

    cwd = os.getcwd()
    os.chdir(BP_DIR)
    run('mkdir -p print && cd src && xelatex -output-directory=../print print.tex')
    run('cd print && bibtex print.aux', env={'BIBINPUTS': '../src'})
    run('cd src && xelatex -output-directory=../print print.tex')
    run('cd src && xelatex -output-directory=../print print.tex')
    run('cp print/print.bbl src/web.bbl')
    os.chdir(cwd)

@task
def web(ctx):
    """
    Build the blueprint website
    """

    cwd = os.getcwd()
    os.chdir(BP_DIR/'src')
    run('plastex -c plastex.cfg web.tex')
    os.chdir(cwd)

    try:
        shutil.copy2(BP_DIR/'print'/'print.pdf', BP_DIR/'web'/'blueprint.pdf')
    except Exception as e:
        print(e)

@task
def serve(ctx, port=8080):
    """
    Serve the blueprint website assuming the blueprint website is already built
    """

    class MyTCPServer(socketserver.TCPServer):
        def server_bind(self):
            import socket
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.socket.bind(self.server_address)

    cwd = os.getcwd()
    os.chdir(BP_DIR/'web')

    Handler = http.server.SimpleHTTPRequestHandler
    httpd = MyTCPServer(('', port), Handler)

    try:
        (ip, port) = httpd.server_address
        ip = ip or 'localhost'
        print(f'Serving http://{ip}:{port}/ ...')
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()

    os.chdir(cwd)

@task(bp, web)
def dev(ctx):
    """
    Serve the blueprint website, rebuild PDF and the website on file changes

    Note: this will not run/rerun task `decls`
    """

    from watchfiles import run_process, DefaultFilter

    def callback(changes):
        print('Changes detected:', changes)
        bp(ctx)
        web(ctx)
    
    run_process(BP_DIR/'src', target='inv serve', callback=callback,
        watch_filter=DefaultFilter(
            ignore_entity_patterns=(
                '.*\.aux$',
                '.*\.log$',
                '.*\.fls$',
                '.*\.fdb_latexmk$',
                '.*\.bbl$',
                '.*\.paux$',
                '.*\.pdf$',
                '.*\.out$',
                '.*\.blg$',
                '.*\.synctex.*$',
                '.*\.w18$'
            )
        ))

@task(decls, bp, web)
def all(ctx):
    """
    Run all tasks: `decls`, `bp`, and `web`
    """
    
    pass