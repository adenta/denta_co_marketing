import { Share2Icon, LinkIcon, ListTreeIcon } from "lucide-react"

import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { useToast } from "@/hooks/useToast"

type Heading = {
  id: string
  level: number
  text: string
}

type PostEnhancementsProps = {
  headings: Heading[]
  title: string
}

export default function PostEnhancements({ headings, title }: PostEnhancementsProps) {
  const toast = useToast()

  const copyLink = async () => {
    if (!navigator.clipboard) {
      toast.error("Clipboard access is unavailable in this browser.")
      return
    }

    await navigator.clipboard.writeText(window.location.href)
    toast.success("Post link copied.")
  }

  return (
    <div className="space-y-4">
      <Card className="rounded-3xl border-border/70 bg-card/90 shadow-sm shadow-black/5">
        <CardHeader className="border-b border-border/70">
          <CardTitle className="flex items-center gap-2 text-sm font-semibold tracking-[0.18em] text-muted-foreground uppercase">
            <Share2Icon className="size-4" />
            Share
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-3 pt-4">
          <p className="text-sm leading-6 text-muted-foreground">
            Keep this handy while iterating on the article layout or sending it around for review.
          </p>
          <Button type="button" className="w-full justify-center" onClick={copyLink}>
            <LinkIcon className="size-4" />
            Copy link
          </Button>
        </CardContent>
      </Card>

      {headings.length > 0 ? (
        <Card className="rounded-3xl border-border/70 bg-card/90 shadow-sm shadow-black/5">
          <CardHeader className="border-b border-border/70">
            <CardTitle className="flex items-center gap-2 text-sm font-semibold tracking-[0.18em] text-muted-foreground uppercase">
              <ListTreeIcon className="size-4" />
              On this page
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-1">
            <Accordion type="single" collapsible defaultValue="toc">
              <AccordionItem value="toc" className="border-none">
                <AccordionTrigger>{title}</AccordionTrigger>
                <AccordionContent>
                  <nav aria-label="Table of contents">
                    <ul className="space-y-2">
                      {headings.map(heading => (
                        <li key={heading.id}>
                          <a
                            href={`#${heading.id}`}
                            className="block text-sm leading-6 text-muted-foreground transition-colors hover:text-foreground"
                            style={{ paddingLeft: `${Math.max(heading.level - 1, 0) * 0.75}rem` }}
                          >
                            {heading.text}
                          </a>
                        </li>
                      ))}
                    </ul>
                  </nav>
                </AccordionContent>
              </AccordionItem>
            </Accordion>
          </CardContent>
        </Card>
      ) : null}
    </div>
  )
}
