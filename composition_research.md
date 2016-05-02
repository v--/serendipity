___Author___: Ianis G. Vasilev

___Date___: 02.05.2016

Although this research is highly subjective, it is my opinion on the "esotericness" of different approaches to algorithmic music generation. Only a few entries are present, since most of the actual algorithms can only be found in research papers and require implementation.

Detailed descriptions and comments about each of the algorithmic classes can be found in [this book](http://www.amazon.com/Algorithmic-Composition-Paradigms-Automated-Generation/dp/321175539X).

Some of them (the ones with a _cursive_ name) are produced pieces, while the other ones are programs that generate music.

___Legend___:

* __(+)__ - Appropriate result
* __(~)__ - Mixed result
* __(-)__ - Esoteric result


# Markov chains

Varying results, very dependent on how exactly is the output being mapped to musical structures.

* (~) B. Bozhanov - [Computoser](http://computoser.com/)
* (+) _L. Hiller, L. Isaacson - [ILLIAC suite](https://www.youtube.com/watch?v=n0njBFLQSk8)_
* (-) _I. Xenakis - [Metastaseis](https://www.youtube.com/watch?v=SZazYFchLRI)_
* (-) F. Patchet - [MaxOrder](http://www.flow-machines.com/maxorder/)


# Generative grammars

There is large number of papers and most of the concentrate on generating grammars from existing music pieces. The output is generally very limited.

* (-) B. Bell, J. Kippen - [Bol Processor](http://bolprocessor.sourceforge.net/)


# Recursive transition networks

These algorithms give the best possible results, because they basically take existing music pieces, split them in different ways and, later on, reconstruct them.
This is definitely the best current composition approach, especially with something carefully crafted like EMI.

* (~) T. Schürger - [SoundHelix](http://www.soundhelix.com/)
* (+) D. Coope - [EMI](http://artsites.ucsc.edu/faculty/cope/experiments.htm)


# Dynamic systems

These methods also have varying results, but seem like a very good option if an "interesting" enough system is selected.
Their best advantage is that they create completely new pieces of music.

* (+) _R. Bidlack - [Chirikov map zeros](http://www.signalsandnoises.com/Works/StorageRings.htm)_
* (~) _R. Bidlack - [Hénon-Heiles system solutions](http://www.signalsandnoises.com/Works/Separatrix.htm)_


# Lindenmayer systems

There are some interesting results, but they seem to have the same problem as generative grammars.

* (~) _D. Johnson - [Brownian Motion multifractal](http://www.tursiops.cc/fm/)_


# Genetic algorithms

Here there are both options for extrapolation and for "music from scratch".
Their main disadvantage is the required human trainings, which can be avoided using neural networks.

* (+) J. Biles - [GenJam](http://igm.rit.edu/~jabics/GenJam.html)
* (+) A. Vartakavi - [geneSynth](http://aneeshvartakavi.com/projects/genesynth/)
* (-) L. Spector - [GenBebop](http://faculty.hampshire.edu/lspector/genbebop.html)


# Cellular automata

Like dynamic systems and Markov chains, these are very dependent on the way the grid state is mapped to music output.
Nonetheless, this seems like the algorithmically simplest approach (assuming discrete-time pink noise belongs here).

* (~) J. Soriano - [Eutérpê Melōidía](http://juankysoriano.com/euterpe-meloidia)
* (-) P. Reiners - [Automatous Monk](http://www.automatous-monk.com/)
* (+) S. Wolfram - [WolframTones](http://tones.wolfram.com/)


# Neural networks

Generally poor performance, unpredictable and very sensitive to underfitting/overfitting. Good results require lots of tuning.

* (+) M. Vitelli, A. Nayebi - [GRUV](https://github.com/MattVitelli/GRUV)
