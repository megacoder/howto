#!/usr/bin/python
# vim: noet sw=4 ts=4

import	sys
import	os
import	subprocess
import	argparse

class	Configure( object ):

	def	__init__( self ):
		pass

	def	run( self, cmd ):
		print '$ {0}'.format( ' '.join( cmd ) )
		err = True
		try:
			output = subprocess.check_output(
				cmd,
				stderr = subprocess.STDOUT
			)
			err = False
		except subprocess.CalledProcessError, e:
			output = e.output
			err = True
		except Exception, e:
			output = '* Failed, error = {0}'.format(
				e.returncode
			)
			err = True
		return err, output

	def	show_namespace( self, ns ):
		pairs = vars(ns)
		for name in sorted( pairs ):
			print '{0:<15}\t{1}'.format(
				name + ':',
				pairs[name]
			)
		return

	def	transcribe( self, err, output ):
		if err:
			fmt = '**{0}'
		else:
			fmt = '  {0}'
		for line in output.splitlines():
			print fmt.format( line )
		return

	def	aclocal( self ):
		cmd = [
			'/bin/aclocal',
			'-I',
			'm4',
			'--install'
		]
		err, output = self.run( cmd )
		self.transcribe( err, output )
		return

	def	autoconf( self ):
		cmd = [
			'/bin/autoconf',
			'-I',
			'm4',
			'--force'
		]
		err, output = self.run( cmd )
		self.transcribe( err, output )
		return

	def	automake( self ):
		cmd = [
			'/bin/automake',
			'--add-missing',
			'--copy',
			'--force-missing'
		]
		err, output = self.run( cmd )
		self.transcribe( err, output )
		return

if __name__ == '__main__':
	print '$ {0}'.format( ' '.join( sys.argv ) )
	p = argparse.ArgumentParser(
		description = 'blah blah blah',
	)
	p.add_argument(
		'-C',
		'--chdir',
		dest = 'run_dir',
		metavar='dir',
		default = None,
		help = 'stuff'
	)
	p.add_argument(
		'-d',
		'--distrib',
		action = 'store_true',
		dest = 'distrib',
		help = 'run using distcc(1)'
	)
	p.add_argument(
		'-f',
		'--force',
		dest = 'force',
		action = 'store_true',
		help = 'blah blah',
	)
	p.add_argument(
		'-j',
		'--jobs',
		dest = 'jobs',
		metavar = 'N',
		default = '5',
		help = 'number of parallel make(1) runs.'
	)
	p.add_argument(
		'-m',
		'--make',
		dest = 'want_make',
		action = 'store_true',
		help = 'run make(1) after comfiguring.'
	)
	p.add_argument(
		'-n',
		'--name',
		dest = 'name',
		metavar = 'NAME',
		default = os.path.basename(
			os.path.splitext( os.getenv( 'PWD' ) )[0]
		),
		help = 'name of program',
	)
	p.add_argument(
		'-v',
		'--verbose',
		dest = 'verbose',
		action = 'store_true',
		help = 'chatter like a molting pidgeon.'
	)
	p.add_argument(
		'pass_thru',
		metavar='arg',
		nargs='*',
		help = 'stuff'
	)
	args = p.parse_args()
	#
	conf = Configure()
	conf.show_namespace( args )
	# -C dir
	if args.run_dir:
		try:
			print '$ cd {0}'.format( args.run_dir )
			os.chdir( args.run_dir )
		except Exception, e:
			print >>sys.stderr, 'Cannot chdir to "{0}"'.format(
				args.run_dir
			)
			raise e
	# --force
	if args.force:
		cmd = [
			'/bin/rm',
			'-f',
			'configure'
		]
		err, output = conf.run( cmd )
		if err:
			for line in output.splitlines():
				print '* {0}'.format( line )
	# Try running 'bootstrap' to get a "./configure" file
	if not os.path.isfile( 'configure' ):
		if os.path.isfile( 'configure.ac' ) or os.path.isfile( 'configure.in' ):
			conf.aclocal()
			conf.autoconf()
		if os.path.isfile( 'Makefile.am' ):
			conf.automake()
			if not os.path.isfile( 'Makefile' ):
				print >>sys.stderr, 'Did not produce a "Makefile" file.'
	# Should have a 'configure' file by noe
	if not os.path.isfile( 'configure' ):
		print >>sys.stderr, 'Did not produce a "./configure" file.'
		exit( 1 )
	# Run the configure script with the desired parameters
	cmd = [
		'./configure',
		'--prefix=/opt/{0}'.format( args.name ),
	] + args.pass_thru
	err, output = conf.run( cmd )
	conf.transcribe( err, output )
	if err:
		exit( 1 )
	if args.want_make:
		cmd = [
			'/bin/make',
			'-j{0}'.format( args.jobs )
		]
		err, output = conf.run( cmd )
		conf.transcribe( err, output )
		if err:
			exit( 1 )
	exit( 0 )
