---
title: 'An NSFW filter for Marginalia Search'
math: 1
date: 2026-03-30
tags:
- search-engine
- nlnet
---

... optional, that is.  

I've been working on an NSFW filter for Marginalia Search,
as that is something some people have asked for,
primarily API consumers.  

The search engine has had some domain based filtering for a while, 
based on the UT1 lists, but that isn't a very comprehensive approach.

We'll land on a single hidden layer neural network approach, 
implemented from scratch, but before landing on that, 
many other things were tried along the way.  

This is largely an abbreviated account of the way there.

---

There is a tension between speed and generality in classification.

Building something that is both fast and reasonably correct in its assessments is incredibly fiddly work,
even if the solution itself is often pretty straightforward.

The main limiting constraint for a filter that runs in a search engine is that it needs to be 
really fast and run well on CPUs.  

This immediately disqualifies transformer-based models and other state-of-the art approaches, 
capable as they are they check neither of those boxes.

## Fasttext

One of the early stabs of the problems I tried was using fasttext,
which is a classifier library from "Facebook, Inc." (back when they were).

It's got a few years on its neck, but it's well named in that it really is fast.
The search engine already uses it for language identification, so no new dependencies!
Worth a try at least.

Problem with training a classifier is that you need sample data,
and kind of a lot of it.   Thankfully, finding candidate samples is easy enough when you run a search engine.
You can just search for them!  Hook up a little script to the API and search
for all manner of depravity, save the results for labeling.

### Training Data 

To get a filter that is half way decent we need tens of thousands of samples,
and as exciting as manually labelling them sounds, I can't help but feel there are
better ways to spend a couple of weeks.

While NSFW sample sets nominally do exist, fast classifiers are very sensitive 
to the context and shape of the data.  

Training a classifier on reddit comments would result in a reddit comment classifier,
and as such would produce dismal results when fed search results.

We can't use state of the art techniques *as the classifier*, 
but that doesn't mean we can't use them to label sample data,
and then use that sample data to train a faster and simpler model.

The generative aspects of LLMs have largely overshadowed 
how good they are at unsupervised classification tasks,
which is a decidedly less glitzy problem domain.  

Open source, self-hostable models are more than capable enough for this task,
so ollama and qwen3.5 makes a compelling all open-source pipeline that can be run on relatively modest consumer hardware.  

1.  Run search queries.
2.  Pass the results to ollama / qwen 3.5 with instructions to output an NSFW classification
3.  Annotate the search results with the label SAFE or NSFW

This is a slow process, measured in seconds per sample rather than the other way around, 
but doesn't need any actual human attention can easily be left to cook for a few days.

The results are probably on par with what I'd expect from a human, 
especially given most humans would be pretty fatigued 10,000 or so labeling decisions in.  

There are many ambiguous cases where a sample could be labeled either NSFW or SAFE depending on
who is reviewing it, there's no getting away from that, but it seemed pretty consistent and made reasonable judgements,
certainly good enough for the task.

### Evaluation

Thus I'd gathered about 10K samples, roughly 60/40 split between NSFW and SAFE, fed it through fasttext to output a model and,
the results were kinda miserable.

The reason it wasn't doing a good job was that the training samples were skewed toward documents that were NSFW-adjacent,
as we'd gathered them by searching for NSFW queries, they all contained search terms that were associated with NSFW content, 
even if they were not always NSFW in themselves.

Fast classifiers are sensitive to stuff like this, and when shown a broader set of search results, they generated a ton of false positives based on noise in the data. 

At this point I *could* have probably grabbed a document database file from one of the search engine partitions,
and ran the qwen classifier over all the ~125M records, and used that instead, but between the fact that this 
would have taken approximately 20 years of constant coil whine, insane electricity bills, and way more BTUs than
my ventilation can handle, this idea was dismissed as impractical.

Problem is that actual NSFW content is relatively rare, so using a representative sample is extremely expensive
with how slow the qwen classifier is on consumer GPUs.   It's doable up to order of 100K samples, but then that's
pretty small given the low base rate.

## The Neural Network

My assumption was that fasttext was picking up irrelevant features in the noise of the data.  

Can we focus the classifier by fixing the features?

I'm going to be honest a big part of this following scheme was inspired by the unreasonable
success of the naive [recipe detector](https://raw.githubusercontent.com/MarginaliaSearch/MarginaliaSearch/refs/heads/master/code/processes/converting-process/java/nu/marginalia/converting/processor/classifier/topic/RecipeDetector.java) the search engine uses.

The plan is something like to pick out terms that seem relevant to separating the wheat from the chaff using human eyeballing,
then build a classifier model based on those handpicked features.

This means first looking for NSFW terms, easy as just grabbing the term frequency list on the NSFW
samples and picking the ones that appear in NSFW contexts. 

But we also want terms that would put NSFW terms in an SFW context.  

feature | disambiguated by
--- | ---
cum | laude
balls | golf, basket
anal | cancer, fissure, gland
sex | change, education

Some of these are funny, but disambiguating terms like 'gay' or 'lesbian' is an actual concern, 
as the filter could easily turn into an inadvertent erasure machine. 

You can get a pretty long way on just making educated guesses, 
but the list of disambiguating terms can be further refined by doing a chi^2 scoring of the term frequencies
of the terms that coincide with each feature, to find disambiguating features.
We might find 'escort' to be a feature that captures escort service spam,
but SAFE samples that contain the word 'escort' often also contain 'ford' or 'destroyer',
so we add those terms too.  Rinse and repeat as we approximate the circle.

Next challenge is to build a classifier that allows a hand picked feature set.
Fasttext does not.  This is a job that a basic neural network should theoretically do a pretty good job at.

Conceptually, it's just binary input signals matching features -> (math) -> probability of NSFW.

After trying some things in python, it seemed that the simplest approach that did a good job for this
was a single hidden layer neural network.  This is also easy enough to implement. 

The math in machine learning looks daunting as there's a lot of dense jargon and partial derivatives, but there's a Scooby-Doo reveal to be had in that underneath the yeti mask it's just the sort of algebra and multivariate calculus most STEM students will have learned in their first year, with some basic linear algebra terminology that doesn't strictly add much understanding.

I will gloss over the implementation details here and set up the equations and derive the math in Appendix B instead. 

All said and done, this model performed better.  Saving some percentage of training data for evaluations, false positive and false negatives were about 10-15%, which looks pretty good, but to be honest, this is the same sort of figures that fasttext's evaluations were claiming as well.  

The whole point of the exercise is to get around the low base rate problem. The real test is running the classifier on real data.  So another script was built, one that grabs search result metadata from the database, labels them with the new model, and if positive, verifies the label using ollama+qwen and then saves the labeled result as more varied training data.  

The results were better.  There were a lot of false positives, but at least generally false positives that made some sense.  Given the low base rate, a lot of false positives is to be expected.  Initially the model sat at around 10% agreement with the classifier, but crept up to 20-30% later on after feeding it with counter-examples from this new script, as well as adding more features.

Evaluating the new filter on actual search results, when fed NSFW terms, at this point let through a decent amount of NSFW results,
problem being that results that only contained one feature and nothing else were essentially ambiguous.  We want the filter to favor rejecting those cases.  So in training, statistics are gathered for the features, for features that appear prominently in both sets, the negative samples are removed with logging to show which terms this is, in case we want to find more disambiguating terms.

This of course means we get more false positives...  As mentioned, this is a very fiddly exercise.

In the end we got there, and this is in production.  It's not perfect, NSFW classifiers never are, but it's doing a pretty good job. For now it's available on the API only, but a UI option will come soon, if nothing else because it makes it easier to evaluate how well it works. 

Public API is prone to rate limiting, but if you have a bit of patience,
you can test it like this:

```bash
Unfiltered:

$ curl -H"API-Key: public" \
  'https://api2.marginalia-search.com/search?query=escort+service&nsfw=0&count=10' \
  | jq '.results[]'

Filtered:

$ curl -H"API-Key: public" \
  'https://api2.marginalia-search.com/search?query=escort+service&nsfw=2&count=10' \
  | jq '.results[]'
```

# Appendix A: Evals

Also as a foot note, these are the training evaluations for the final filter:

Label | Value
---|---
Total Samples | 3817
Correct | 3439
Accuracy | 90.10%
True positives | 1415
False positives | 185
True negatives | 2024
False negatives | 193
Precision | 88.44%
Recall | 88.00%
F1 | 0.8822

For 43,000 training samples, 2000 epochs, and a learning rate of 0.01, lowered by 2% every 200 epochs.

Though I'd take it with a grain of salt, as we've discussed, the base rate of NSFW results is fairly low,
so the practical false positive figures are *much* worse. 

# Appendix B:  Single Layer Neural Network

I ended up implementing the network several times,
first in python using high level libraries, 
then in Java as a paint by numbers affair following blog posts and asking LLMs for advice when it wasn't working,
but I'm really not happy writing code I don't understand, 
so I kept at it until I was able to implement the network from scratch from first principles.

This is a cleaned up version of my notes from that exercise. 

This is mostly for my own benefit,
you don't understand what you can't teach and so on,
but you're free to get lost in the chain rules with me.

We have a neural network that consists of N inputs,
that pass into a hidden layer of M nodes,
that all go into a single output node.

It is conventional to make an illustration of a neural network as a sort of graph at this point,
which makes it feel like you understand it,
but such an illustration doesn't really add any *meaningful* intuition,
so I'll refrain from that step.

I developed an allergy to Schrodinger's cat as a physics student.
It always makes me itch when you start with a hand-wavey metaphor, and then jump into the equations,
and then never look back at the metaphor again.

If you're looking for that sort of explainer, 
here's [a blog post series](https://machinelearning.tobiashill.se/2018/11/28/part-1-neural-network-from-scratch/) that does a pretty good job at motivating how the intuitive graph and the practical matrices go together, though with a slightly different network design.

This isn't a machine learning textbook and I'll keep the scope fairly limited.
There's a fractal of details and decisions I won't motivate,
we'll use this and that activation function and loss function,
and within the scope of this derivation, that's just what you do--a brute fact,
like God gave Moses his tablets, 
we were handed these standard construction choices for our model. 

--- 

Our model consists of four equations, each feeding into the next.

Hidden layer pre-activation:

$$z^{(1)}_i = \sum_{j=0}^{N} w^{(1)}_{(i,j)} x_j + b^{(1)}_i$$

Hidden layer activation:

$$a_i(z_i^{(1)}) = \sigma_1(z_i^{(1)})$$

Output layer pre-activation:

$$z^{(2)} = \sum_{i=0}^{M} w^{(2)}_{i} a_i(z^{(1)}_i) + b_2$$

Output layer activation:

$$\hat{y}(z^{(2)}) = \sigma_2(z^{(2)})$$

\(x\) is the input of the model, and \(\hat{y}\) is the output, or prediction.
Feed the input into the first equation, get the prediction out of the last. 

The constants \(w^{(1)}_{i,j}\), \(b^{(1)}_i\), \(w^{(2)}_{i}\) and \(b^{(2)}\) are the weights and biases of the model,
which is what we will be trying to arrive at, such that the model predicts the sample data.  

We also have two activation functions:

ReLU
$$\sigma_1(\chi) = \max(0,\chi)$$

Sigmoid
$$\sigma_2(\chi) = \frac{1}{1 + e^{-\chi}}$$

The functions \(\sigma_1(z^{(1)})\) and \(\sigma_2(z^{(2)})\) introduce non-linearity which is necessary to avoid the neural network from collapsing into a linear algebra exercise that could be solved with Gauss elimination. 


## Prediction
Prediction at this point is as easy as translating these equations into code

```java
    public double predict(BitSet x) {
        // initialize z1 to the hidden layer biases
        double[] z1 = Arrays.copyOf(b1, M_HIDDEN);

        // z1(x)[i] = w1[i][j] * x[j] + b1[i]
        for (int i = 0; i < M_HIDDEN; i++) {
            for (int j = 0; j < N_INPUTS; j++) {
                if (x.get(j))
                    z1[i] += w1[i][j];
            }
        }

        // Implementation note: Here we alias the arrays to save allocations
        // z1 is garbled after the following loop
        double[] a = z1;

        // a[i] = σ1(z1[i])
        for (int i = 0; i < M_HIDDEN; i++) {
            a[i] = σ1.f(z1[i]);
        }

        // z2(a) = w2[i] * a[i] + b2
        double z2 = b2;
        for (int h = 0; h < M_HIDDEN; h++) {
            z2 += a[h] * w2[h];
        }

        // y = σ2(z2)
        return σ2.f(z2);
    }
```

So far it's pretty straight forward, but without appropriate values for the weights and biases, 
this neural network will say that nothing is NSFW, which to be fair, thanks to the low base rate of NSFW content
is pretty good, but not really what we had in mind.

## Training

To train this thing, we need something to optimize.  We choose a loss function, \(L\), to be the binary cross-entropy.

$$ L = -y_0 * log(\hat{y}) - (1 - y_0) log (1 - \hat{y}) $$

Here \(y_0\) is the training value, and \(\hat{y}\) is the predicted value.  While translating this to code,
we need to introduce the additional limitation of clamping \(\hat{y}\) to some region \([\epsilon, 1-\epsilon]\),
to avoid the \(log(...)\) terms introducing NaNs.  In the spirit of Socrates, we can never allow the network to be fully certain.

For each sample, we want to figure out how to minimize L.

The way we do that is through gradient descent.  We calculate \(\frac{\partial L}{\partial ...}\) for each weight and bias,
and adjust the value proportionally.

Particularly the updates will be

$$ w^{(2)}_i := w^{(2)}_i - \rho \frac{\partial L}{\partial w^{(2)}_i} $$
$$ b^{(2)} := b^{(2)} - \rho \frac{\partial L}{\partial b^{(2)}} $$
$$ w^{(1)}_{i,j} := w^{(1)}_{i,j} - \rho \frac{\partial L}{\partial w^{(1)}_{i,j}} $$
$$ b^{(1)}_i := b^{(1)}_i - \rho \frac{\partial L}{\partial b^{(1)}_i} $$

for learning rate \(\rho\).

To get from L to these mystery partial derivatives really is just chain rules and kindergarten algebra.

### Finding the output layer parameters

Let's start working our way backwards from the loss function.  The parameters for the output node are the most immediately accessible.

$$ \frac{\partial L}{\partial w_i^{(2)}} = \frac{\partial L}{\partial z^{(2)}} \frac{\partial z^{(2)}}{\partial w_i^{(2)}} = \frac{\partial L}{\partial z^{(2)}} a_i$$
$$ \frac{\partial L}{\partial b^{(2)}} = \frac{\partial L}{\partial z^{(2)}} \frac{\partial z^{(2)}}{\partial b^{(2)}} = \frac{\partial L}{\partial z^{(2)}} $$

We can find \(\frac{\partial L}{\partial z^{(2)}}\)

$$ \frac{\partial L}{\partial z^{(2)}} = \frac{\partial L}{\partial \hat{y}} \frac{\partial \hat{y}}{\partial z^{(2)}} $$

We kinda want to approach both terms at the same time, since they partially cancel out

$$ \frac{\partial L}{\partial \hat{y}} = \frac { \hat{y} - y_0 } { \hat{y} (1 - \hat{y} )} $$

The derivative of the sigmoid function is \(\frac{d\sigma_2}{d\chi} = \sigma_2(\chi)(1-\sigma_2(\chi))\),
which (since as you'll recall \(\hat{y} = \sigma_2(z^{(2)})\)) is what we see in the denominator,
thus the partial falls out to 

$$ \frac{\partial L}{\partial z^{(2)}} = \hat{y} - y_0 $$

We now have two of the two mystery derivatives!

$$ \frac{\partial L}{\partial w_i^{(2)}} = (\hat{y} - y_0) a_i$$
$$ \frac{\partial L}{\partial b^{(2)}} = \hat{y} - y_0 $$

### Finding the hidden layer parameters

We approach the remaining two derivatives much the same.

We're looking for the rate of change of the weights and biases of the hidden layer.

$$ w^{(1)}_{i,j} := w^{(1)}_{i,j} - \rho \frac{\partial L}{\partial w^{(1)}_{i,j}} $$
$$ b^{(1)}_i := b^{(1)}_i - \rho \frac{\partial L}{\partial b^{(1)}_i} $$

Given we already know \(\frac{\partial L}{\partial z^{(2)}}\), we can use that as a basis.


$$ \frac{\partial L}{\partial w^{(1)}_{i,j}} = \frac{\partial L}{\partial z^{(2)}_{i}}  \frac{\partial z^{(2)}_i}{\partial z^{(1)}_i} \frac{\partial z^{(1)}_i}{\partial w^{(1)}_{i,j}} = (\hat{y} - y_0) w^{(2)}_i\frac{\partial \sigma_1}{\partial z^{(1)}_i} x_j $$
$$ \frac{\partial L}{\partial b^{(1)}_{i}} = \frac{\partial L}{\partial z^{(2)}_{i}}  \frac{\partial z^{(2)}_i}{\partial z^{(1)}_i} \frac{\partial z^{(1)}_i}{\partial b^{(1)}_{i}} = (\hat{y} - y_0) w^{(2)}_i\frac{\partial \sigma_1}{\partial z^{(1)}_i} $$

With 

$$ \frac{d\sigma_1(\chi)}{d\chi} = \begin{cases}
    0 & \text{if } x \leq 0 \\
    1 & \text{if } x > 0
\end{cases} $$

That's all the equations we need!  In terms of code, we need to be careful about the order in which the
parameters are updated, as we note that the hidden layer weights and biases depend on the output layer weights and biases.


```java

    public double trainSample(double y0, int[] x, double lr) {

        // Step 1:  Forward propagation
    
        // Hidden layer preactivation
        double[] z1 = Arrays.copyOf(b1, M_HIDDEN);
        for (int i = 0; i < M_HIDDEN; i++) {
            for (int xi : x) {
                z1[i] += w1[i][xi];
            }
        }

        // Hidden layer activation
        double[] a = new double[M_HIDDEN];
        for (int i = 0; i < M_HIDDEN; i++) {
            a[i] = σ1.f(z1[i]);
        }

        // Output layer preactivation
        double z2 = b2;
        for (int h = 0; h < M_HIDDEN; h++) {
            z2 += a[h] * w2[h];
        }

        // Output activation (i.e. make a prediction)
        double y = σ2.f(z2);

        // Step 2:  Evaluate the loss function

        final double eps = 1E-14;
        final double y_clamped = Math.clamp(y, eps, 1-eps);
        double L =  - y0 * log(y_clamped)
                - (1 - y0) * log(1 - y_clamped);

        // Step 3: Backpropagation via gradient descent!

        final double dL_dz2 = y - y0;


        for (int i = 0; i < M_HIDDEN; i++) {

            double dLdz1 = dL_dz2 * w2[i]
                    * σ1.f_deriv(z1[i]);

            for (int xi : x) {
                w1[i][xi] -= lr * dLdz1;
            }
            
            b1[i] -= lr * dLdz1;
        }


        for (int i = 0; i < M_HIDDEN; i++) {
            double dz2_dw2 = a[i];
            
            w2[i] -= lr * dL_dz2 * dz2_dw2;
        }
        
        b2 -= lr * dL_dz2;


        return L;
    }
```
